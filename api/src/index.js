// api.qissora.app: redeems the codes that open Premium for free.
//
//   POST /codes/redeem   { code, idToken }  -> { kind, expiresAt, ticket }
//   POST /codes/restore  { idToken }        -> { kind, expiresAt, ticket }
//   POST /codes/check    { ticket }         -> { active, kind, expiresAt }
//
// A VIP code is for one family, for a year. A school code is one code for a
// whole school; each family that enters it gets a month, and a family gets a
// school trial only once, whichever school it came from.
//
// idToken is the Google ID token of the parent signed in on the phone; the
// Google account it names is who a redemption belongs to. expiresAt is in
// milliseconds since the epoch.

import { hashAccount, hashCode, isWellFormed, normalizeCode } from './codes.js';

export const DAY = 86_400_000;

const FAILURE_WINDOW = 60 * 60 * 1000;
const MAX_FAILURES = 10;

export default {
  fetch: (request, env) => handle(request, env),
};

/**
 * [verify] turns an ID token into a Google account id, or null. Tests pass
 * their own so they never reach Google.
 */
export async function handle(
  request,
  env,
  { verify = verifyGoogleToken, now = Date.now } = {},
) {
  const { pathname } = new URL(request.url);
  if (request.method !== 'POST') return json({ error: 'not_found' }, 404);

  let body;
  try {
    body = await request.json();
  } catch {
    return json({ error: 'bad_request' }, 400);
  }
  if (body === null || typeof body !== 'object') {
    return json({ error: 'bad_request' }, 400);
  }

  const ctx = { env, db: env.DB, verify, now: now() };
  switch (pathname) {
    case '/codes/redeem':
      return redeem(body, ctx);
    case '/codes/restore':
      return restore(body, ctx);
    case '/codes/check':
      return check(body, ctx);
    default:
      return json({ error: 'not_found' }, 404);
  }
}

async function redeem({ code, idToken }, ctx) {
  if (typeof code !== 'string' || typeof idToken !== 'string') {
    return json({ error: 'bad_request' }, 400);
  }
  const account = await accountFor(idToken, ctx);
  if (!account) return json({ error: 'bad_token' }, 401);

  const failures = await ctx.db
    .prepare(
      'SELECT COUNT(*) AS n FROM redeem_failures WHERE account_hash = ? AND at > ?',
    )
    .bind(account, ctx.now - FAILURE_WINDOW)
    .first('n');
  if (failures >= MAX_FAILURES) return json({ error: 'too_many_tries' }, 429);

  const normalized = normalizeCode(code);
  const codeHash = isWellFormed(normalized)
    ? await hashCode(ctx.env.VIP_PEPPER, normalized)
    : null;
  const row = codeHash
    ? await ctx.db
        .prepare('SELECT * FROM codes WHERE code_hash = ?')
        .bind(codeHash)
        .first()
    : null;
  if (!row || row.revoked_at != null) {
    await recordFailure(account, ctx);
    return json({ error: 'invalid' }, 404);
  }

  // The same family entering its code again, e.g. on a second phone.
  const mine = await redemptionOf(codeHash, account, ctx);
  if (mine) return grantOrExpired(mine, ctx);

  if (row.kind === 'school') {
    const hadTrial = await ctx.db
      .prepare(
        "SELECT 1 AS yes FROM redemptions WHERE account_hash = ? AND kind = 'school' LIMIT 1",
      )
      .bind(account)
      .first();
    if (hadTrial) return json({ error: 'trial_used' }, 409);
  }

  const ticket = randomTicket();
  const expiresAt = ctx.now + row.days * DAY;
  // Takes a place only while the code has one left, in a single statement
  // so two families redeeming the last place at once cannot both get it.
  const result = await ctx.db
    .prepare(
      `INSERT OR IGNORE INTO redemptions
         (code_hash, account_hash, kind, redeemed_at, expires_at, ticket)
       SELECT ?, ?, ?, ?, ?, ?
        WHERE (SELECT COUNT(*) FROM redemptions WHERE code_hash = ?) < ?`,
    )
    .bind(codeHash, account, row.kind, ctx.now, expiresAt, ticket, codeHash, row.max_uses)
    .run();
  if (result.meta.changes === 1) {
    return json({ kind: row.kind, expiresAt, ticket });
  }

  const raced = await redemptionOf(codeHash, account, ctx);
  if (raced) return grantOrExpired(raced, ctx);
  if (row.kind === 'vip') {
    // Counted as a failure, so a used code cannot be used to probe.
    await recordFailure(account, ctx);
    return json({ error: 'used' }, 409);
  }
  return json({ error: 'full' }, 409);
}

async function restore({ idToken }, ctx) {
  if (typeof idToken !== 'string') return json({ error: 'bad_request' }, 400);
  const account = await accountFor(idToken, ctx);
  if (!account) return json({ error: 'bad_token' }, 401);

  const row = await ctx.db
    .prepare(
      `SELECT r.kind, r.expires_at, r.ticket
         FROM redemptions r JOIN codes c ON c.code_hash = r.code_hash
        WHERE r.account_hash = ? AND c.revoked_at IS NULL AND r.expires_at > ?
        ORDER BY r.expires_at DESC LIMIT 1`,
    )
    .bind(account, ctx.now)
    .first();
  if (!row) return json({ error: 'none' }, 404);
  return json({ kind: row.kind, expiresAt: row.expires_at, ticket: row.ticket });
}

async function check({ ticket }, ctx) {
  if (typeof ticket !== 'string') return json({ error: 'bad_request' }, 400);
  const row = await ctx.db
    .prepare(
      `SELECT r.kind, r.expires_at, c.revoked_at
         FROM redemptions r JOIN codes c ON c.code_hash = r.code_hash
        WHERE r.ticket = ?`,
    )
    .bind(ticket)
    .first();
  if (!row || row.revoked_at != null) return json({ active: false });
  return json({
    active: row.expires_at > ctx.now,
    kind: row.kind,
    expiresAt: row.expires_at,
  });
}

function redemptionOf(codeHash, account, ctx) {
  return ctx.db
    .prepare(
      'SELECT kind, expires_at, ticket FROM redemptions WHERE code_hash = ? AND account_hash = ?',
    )
    .bind(codeHash, account)
    .first();
}

function grantOrExpired(r, ctx) {
  return r.expires_at > ctx.now
    ? json({ kind: r.kind, expiresAt: r.expires_at, ticket: r.ticket })
    : json({ error: 'expired' }, 410);
}

async function accountFor(idToken, ctx) {
  const sub = await ctx.verify(idToken, ctx.env.GOOGLE_CLIENT_ID);
  return sub ? hashAccount(ctx.env.VIP_PEPPER, sub) : null;
}

async function recordFailure(account, ctx) {
  await ctx.db
    .prepare('DELETE FROM redeem_failures WHERE at <= ?')
    .bind(ctx.now - FAILURE_WINDOW)
    .run();
  await ctx.db
    .prepare('INSERT INTO redeem_failures (account_hash, at) VALUES (?, ?)')
    .bind(account, ctx.now)
    .run();
}

/**
 * Asks Google whether [idToken] is a live token issued to our app, and
 * returns the account id it names.
 */
export async function verifyGoogleToken(idToken, clientId) {
  const res = await fetch(
    `https://oauth2.googleapis.com/tokeninfo?id_token=${encodeURIComponent(idToken)}`,
  );
  if (!res.ok) return null;
  const info = await res.json();
  if (info.aud !== clientId) return null;
  if (!['accounts.google.com', 'https://accounts.google.com'].includes(info.iss)) {
    return null;
  }
  if (Number(info.exp) * 1000 <= Date.now()) return null;
  return typeof info.sub === 'string' && info.sub ? info.sub : null;
}

function randomTicket() {
  const bytes = crypto.getRandomValues(new Uint8Array(16));
  return [...bytes].map((b) => b.toString(16).padStart(2, '0')).join('');
}

function json(data, status = 200) {
  return new Response(JSON.stringify(data), {
    status,
    headers: { 'content-type': 'application/json' },
  });
}
