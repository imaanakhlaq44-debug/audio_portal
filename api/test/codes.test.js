// node --test api/test/codes.test.js
//
// Runs the Worker against a real SQLite database (node:sqlite) wearing just
// enough of D1's API, so the SQL is exercised as written.

import assert from 'node:assert/strict';
import { readFileSync } from 'node:fs';
import { DatabaseSync } from 'node:sqlite';
import { beforeEach, describe, test } from 'node:test';

import { hashCode, isWellFormed, newCode, normalizeCode } from '../src/codes.js';
import { DAY, handle } from '../src/index.js';

const schema = readFileSync(
  new URL('../migrations/0001_codes.sql', import.meta.url),
  'utf8',
);
const PEPPER = 'test-pepper';

class FakeD1 {
  constructor() {
    this.sqlite = new DatabaseSync(':memory:');
    this.sqlite.exec(schema);
  }

  prepare(sql) {
    const sqlite = this.sqlite;
    let args = [];
    const statement = {
      bind(...values) {
        args = values;
        return statement;
      },
      async first(column) {
        const row = sqlite.prepare(sql).get(...args);
        if (!row) return null;
        return column ? row[column] : { ...row };
      },
      async run() {
        const result = sqlite.prepare(sql).run(...args);
        return { meta: { changes: Number(result.changes) } };
      },
    };
    return statement;
  }
}

// Tokens are just "token-<account>" here.
const verify = async (token) =>
  token.startsWith('token-') ? token.slice('token-'.length) : null;

let db;
let clock;

async function call(path, body) {
  const res = await handle(
    new Request(`https://api.qissora.app${path}`, {
      method: 'POST',
      body: JSON.stringify(body),
    }),
    { DB: db, VIP_PEPPER: PEPPER, GOOGLE_CLIENT_ID: 'client' },
    { verify, now: () => clock },
  );
  return { status: res.status, body: await res.json() };
}

const redeem = (code, who) =>
  call('/codes/redeem', { code, idToken: `token-${who}` });

async function addCode(code, { kind = 'vip', days = 365, maxUses = 1 } = {}) {
  db.sqlite
    .prepare(
      'INSERT INTO codes (code_hash, kind, days, max_uses, created_at) VALUES (?, ?, ?, ?, ?)',
    )
    .run(await hashCode(PEPPER, code), kind, days, maxUses, clock);
}

const addSchool = (code, maxUses = 500) =>
  addCode(code, { kind: 'school', days: 30, maxUses });

beforeEach(() => {
  db = new FakeD1();
  clock = Date.UTC(2026, 9, 1);
});

describe('codes', () => {
  test('new codes are well formed, and typing them loosely still matches', () => {
    for (let i = 0; i < 200; i++) {
      for (const [kind, prefix] of [['vip', 'QV'], ['school', 'QS']]) {
        const code = newCode(kind);
        assert.match(code, new RegExp(`^${prefix}-[A-Z0-9]{4}-[A-Z0-9]{4}$`));
        assert.ok(isWellFormed(normalizeCode(` ${code.toLowerCase()} `)), code);
      }
    }
  });

  test('hashes ignore dashes and case', async () => {
    assert.equal(
      await hashCode(PEPPER, 'QV-ABCD-2345'),
      await hashCode(PEPPER, 'qvabcd2345'),
    );
  });
});

describe('a VIP code', () => {
  test('opens Premium for a year and hands back a ticket', async () => {
    await addCode('QV-ABCD-2345');
    const res = await redeem('qv-abcd-2345', 'amina');
    assert.equal(res.status, 200);
    assert.equal(res.body.kind, 'vip');
    assert.equal(res.body.expiresAt, clock + 365 * DAY);
    assert.match(res.body.ticket, /^[0-9a-f]{32}$/);
  });

  test('the same family can enter it again and keeps its original year', async () => {
    await addCode('QV-ABCD-2345');
    const first = await redeem('QV-ABCD-2345', 'amina');
    clock += 30 * DAY;
    const again = await redeem('QV-ABCD-2345', 'amina');
    assert.equal(again.status, 200);
    assert.deepEqual(again.body, first.body);
  });

  test('belongs to the first account; anyone else is told it is used', async () => {
    await addCode('QV-ABCD-2345');
    await redeem('QV-ABCD-2345', 'amina');
    const res = await redeem('QV-ABCD-2345', 'bilal');
    assert.equal(res.status, 409);
    assert.equal(res.body.error, 'used');
  });

  test('a made-up or revoked code is invalid', async () => {
    assert.equal((await redeem('QV-ZZZZ-ZZZZ', 'amina')).status, 404);

    await addCode('QV-ABCD-2345');
    db.sqlite.prepare('UPDATE codes SET revoked_at = 1').run();
    const revoked = await redeem('QV-ABCD-2345', 'amina');
    assert.equal(revoked.status, 404);
    assert.equal(revoked.body.error, 'invalid');
  });

  test('says so once the year is over', async () => {
    await addCode('QV-ABCD-2345');
    await redeem('QV-ABCD-2345', 'amina');
    clock += 365 * DAY;
    assert.equal((await redeem('QV-ABCD-2345', 'amina')).status, 410);
  });
});

describe('a school code', () => {
  test('gives every family its own month from the day it enters it', async () => {
    await addSchool('QS-ABCD-2345');
    const amina = await redeem('QS-ABCD-2345', 'amina');
    clock += 10 * DAY;
    const bilal = await redeem('QS-ABCD-2345', 'bilal');

    assert.equal(amina.status, 200);
    assert.equal(amina.body.kind, 'school');
    assert.equal(amina.body.expiresAt, Date.UTC(2026, 9, 1) + 30 * DAY);
    assert.equal(bilal.body.expiresAt, clock + 30 * DAY);
    assert.notEqual(amina.body.ticket, bilal.body.ticket);
  });

  test('stops at its limit', async () => {
    await addSchool('QS-ABCD-2345', 2);
    assert.equal((await redeem('QS-ABCD-2345', 'a')).status, 200);
    assert.equal((await redeem('QS-ABCD-2345', 'b')).status, 200);
    const third = await redeem('QS-ABCD-2345', 'c');
    assert.equal(third.status, 409);
    assert.equal(third.body.error, 'full');
    // Someone already in can still enter it again.
    assert.equal((await redeem('QS-ABCD-2345', 'a')).status, 200);
  });

  test('is a family\'s only school trial, whichever school it came from', async () => {
    await addSchool('QS-ABCD-2345');
    await addSchool('QS-WXYZ-6789');
    await redeem('QS-ABCD-2345', 'amina');
    clock += 31 * DAY;
    const second = await redeem('QS-WXYZ-6789', 'amina');
    assert.equal(second.status, 409);
    assert.equal(second.body.error, 'trial_used');
  });

  test('does not stand in the way of a VIP code', async () => {
    await addSchool('QS-ABCD-2345');
    await addCode('QV-ABCD-2345');
    await redeem('QS-ABCD-2345', 'amina');
    const vip = await redeem('QV-ABCD-2345', 'amina');
    assert.equal(vip.status, 200);
    assert.equal(vip.body.kind, 'vip');
  });

  test('revoked, ends every family\'s trial', async () => {
    await addSchool('QS-ABCD-2345');
    const { body } = await redeem('QS-ABCD-2345', 'amina');
    db.sqlite.prepare('UPDATE codes SET revoked_at = 1').run();
    assert.deepEqual((await call('/codes/check', { ticket: body.ticket })).body, {
      active: false,
    });
    assert.equal((await call('/codes/restore', { idToken: 'token-amina' })).status, 404);
  });
});

describe('guarding against guessing', () => {
  test('stops an account after ten wrong codes in an hour', async () => {
    await addCode('QV-ABCD-2345');
    for (let i = 0; i < 10; i++) await redeem('QV-WRNG-CDEF', 'eve');
    assert.equal((await redeem('QV-ABCD-2345', 'eve')).status, 429);

    clock += 61 * 60 * 1000;
    assert.equal((await redeem('QV-ABCD-2345', 'eve')).status, 200);
  });

  test('needs a real Google token', async () => {
    await addCode('QV-ABCD-2345');
    const res = await call('/codes/redeem', {
      code: 'QV-ABCD-2345',
      idToken: 'forged',
    });
    assert.equal(res.status, 401);
  });

  test('rejects anything that is not a POST with a JSON body', async () => {
    const get = await handle(
      new Request('https://api.qissora.app/codes/redeem'),
      { DB: db, VIP_PEPPER: PEPPER },
      { verify },
    );
    assert.equal(get.status, 404);
    assert.equal((await call('/codes/redeem', { code: 7 })).status, 400);
  });
});

describe('restore', () => {
  test('finds the code on a new phone from the Google account alone', async () => {
    await addCode('QV-ABCD-2345');
    const redeemed = await redeem('QV-ABCD-2345', 'amina');
    const res = await call('/codes/restore', { idToken: 'token-amina' });
    assert.equal(res.status, 200);
    assert.deepEqual(res.body, redeemed.body);
    assert.equal((await call('/codes/restore', { idToken: 'token-bilal' })).status, 404);
  });

  test('prefers whichever code lasts longest', async () => {
    await addCode('QV-ABCD-2345');
    await addSchool('QS-ABCD-2345');
    await redeem('QV-ABCD-2345', 'amina');
    await redeem('QS-ABCD-2345', 'amina');
    const res = await call('/codes/restore', { idToken: 'token-amina' });
    assert.equal(res.body.kind, 'vip');
  });

  test('finds nothing once the time is over', async () => {
    await addSchool('QS-ABCD-2345');
    await redeem('QS-ABCD-2345', 'amina');
    clock += 30 * DAY;
    assert.equal((await call('/codes/restore', { idToken: 'token-amina' })).status, 404);
  });
});

describe('check', () => {
  test('reports a live code, then a revoked one as inactive', async () => {
    await addCode('QV-ABCD-2345');
    const { body } = await redeem('QV-ABCD-2345', 'amina');
    const live = await call('/codes/check', { ticket: body.ticket });
    assert.deepEqual(live.body, {
      active: true,
      kind: 'vip',
      expiresAt: body.expiresAt,
    });

    db.sqlite.prepare('UPDATE codes SET revoked_at = 1').run();
    const revoked = await call('/codes/check', { ticket: body.ticket });
    assert.deepEqual(revoked.body, { active: false });
  });

  test('an unknown ticket is simply inactive', async () => {
    const res = await call('/codes/check', { ticket: 'nope' });
    assert.deepEqual(res.body, { active: false });
  });
});
