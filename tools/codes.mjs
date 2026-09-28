// Codes that open Premium for free.
//
//   node tools/codes.mjs setup                         make the pepper (once)
//   node tools/codes.mjs vip [count]                   VIP codes: one family,
//                                                      a year (default 50)
//   node tools/codes.mjs school "<school>" [--uses N]  one code for a school:
//                                                      a month per family, for
//                                                      up to N families (500)
//   node tools/codes.mjs schools [count] [--uses N]    school codes to hand out
//                                                      later; label each one
//                                                      when it is given
//   node tools/codes.mjs list                          every code and its state
//   node tools/codes.mjs export [file]                 the list as a CSV to keep
//                                                      (api/codes-export.csv)
//   node tools/codes.mjs label <code> <name>           note who a code went to
//   node tools/codes.mjs revoke <code>                 switch a code off
//
// Add --local to any of them to work on `wrangler dev`'s database instead of
// the live one. Needs `npm install` in api/ first.
//
// The codes are written to api/codes.local.csv, which is git-ignored and is
// the only place they exist in readable form: the database holds hashes.
// Lose that file and the codes can no longer be listed, only revoked.

import { execFileSync } from 'node:child_process';
import { randomBytes } from 'node:crypto';
import { appendFileSync, existsSync, readFileSync, writeFileSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { dirname, join } from 'node:path';
import { fileURLToPath } from 'node:url';

import { hashCode, isWellFormed, newCode, normalizeCode } from '../api/src/codes.js';

const api = join(dirname(fileURLToPath(import.meta.url)), '..', 'api');
const devVars = join(api, '.dev.vars');
const codesFile = join(api, 'codes.local.csv');
const wranglerBin = join(api, 'node_modules', 'wrangler', 'bin', 'wrangler.js');

const VIP_DAYS = 365;
const SCHOOL_DAYS = 30;

const args = process.argv.slice(2);
const local = args.includes('--local');
const usesAt = args.indexOf('--uses');
const uses = usesAt === -1 ? 500 : Number(args[usesAt + 1]);
const [command, ...rest] = args.filter(
  (a, i) => a !== '--local' && i !== usesAt && (usesAt === -1 || i !== usesAt + 1),
);

switch (command) {
  case 'setup':
    setup();
    break;
  case 'vip':
    await vip(Number(rest[0] ?? 50));
    break;
  case 'school':
    await school(rest.join(' '));
    break;
  case 'schools':
    await schools(Number(rest[0] ?? 50));
    break;
  case 'list':
    await list();
    break;
  case 'export':
    await exportCsv(rest[0] ?? join(api, 'codes-export.csv'));
    break;
  case 'label':
    await label(rest[0], rest.slice(1).join(' '));
    break;
  case 'revoke':
    await revoke(rest[0]);
    break;
  default:
    console.log(readFileSync(fileURLToPath(import.meta.url), 'utf8').split('\n\n')[0]);
    process.exit(command ? 1 : 0);
}

function setup() {
  if (pepperOrNull()) {
    console.log(`A pepper is already in ${devVars}. Changing it would break every code made with it.`);
    return;
  }
  const pepper = randomBytes(32).toString('hex');
  appendFileSync(devVars, `VIP_PEPPER=${pepper}\n`);
  console.log(`Wrote a new pepper to ${devVars}. Keep a copy of that file somewhere safe.`);
  console.log('Give the live Worker the same one:');
  console.log('  cd api && npx wrangler secret put VIP_PEPPER');
  console.log(`and paste: ${pepper}`);
}

async function vip(count) {
  if (!Number.isInteger(count) || count < 1 || count > 500) fail('count must be 1-500');
  const codes = await add('vip', count, { days: VIP_DAYS, maxUses: 1 });
  console.log(codes.join('\n'));
  console.log(`\n${count} VIP codes added, and saved to ${codesFile}.`);
}

async function school(name) {
  if (!name) fail('usage: school "<school name>" [--uses N]');
  if (!Number.isInteger(uses) || uses < 1 || uses > 100000) fail('--uses must be 1-100000');
  const [code] = await add('school', 1, { days: SCHOOL_DAYS, maxUses: uses, label: name });
  console.log(code);
  console.log(`\nSchool code for ${name}: a month of Premium for each of up to ${uses} families.`);
  console.log(`Saved to ${codesFile}.`);
}

async function schools(count) {
  if (!Number.isInteger(count) || count < 1 || count > 500) fail('count must be 1-500');
  if (!Number.isInteger(uses) || uses < 1 || uses > 100000) fail('--uses must be 1-100000');
  const codes = await add('school', count, { days: SCHOOL_DAYS, maxUses: uses });
  console.log(codes.join('\n'));
  console.log(`\n${count} school codes added, each a month of Premium for up to ${uses} families.`);
  console.log(`Saved to ${codesFile}. Label each one when you give it to a school.`);
}

async function add(kind, count, { days, maxUses, label = null }) {
  const pepper = requirePepper();
  const now = Date.now();
  const codes = Array.from({ length: count }, () => newCode(kind));
  const rows = await Promise.all(
    codes.map(
      async (c) =>
        `('${await hashCode(pepper, c)}', '${kind}', ${sql(label)}, ${days}, ${maxUses}, ${now})`,
    ),
  );
  runFile(
    `INSERT INTO codes (code_hash, kind, label, days, max_uses, created_at) VALUES\n${rows.join(',\n')};`,
  );

  if (!existsSync(codesFile)) writeFileSync(codesFile, 'code,kind,created\n');
  const created = new Date(now).toISOString();
  appendFileSync(codesFile, codes.map((c) => `${c},${kind},${created}\n`).join(''));
  return codes;
}

async function list() {
  const table = await states();
  console.table(table);
  const vips = table.filter((t) => t.kind === 'vip');
  const count = (s) => vips.filter((t) => t.state.startsWith(s)).length;
  console.log(
    `${vips.length} VIP codes: ${count('unused')} unused, ${count('active')} active, ` +
      `${count('ended')} ended, ${count('revoked')} revoked. ` +
      `${table.length - vips.length} school codes.`,
  );
}

async function exportCsv(file) {
  const table = await states();
  const cell = (v) => (/[",\n]/.test(v) ? `"${v.replaceAll('"', '""')}"` : v);
  const lines = ['code,kind,given to,state'].concat(
    table.map((t) => [t.code, t.kind, t['given to'], t.state].map(cell).join(',')),
  );
  // A byte-order mark so Excel reads it as UTF-8.
  writeFileSync(file, `\uFEFF${lines.join('\r\n')}\r\n`);
  console.log(`${table.length} codes written to ${file}`);
}

/** Every code in the database, with who has it and how it is being used. */
async function states() {
  const pepper = requirePepper();
  const known = new Map();
  if (existsSync(codesFile)) {
    for (const line of readFileSync(codesFile, 'utf8').split('\n').slice(1)) {
      const code = line.split(',')[0];
      if (code) known.set(await hashCode(pepper, code), code);
    }
  }
  const now = Date.now();
  const rows = query(
    `SELECT c.code_hash, c.kind, c.label, c.max_uses, c.revoked_at,
            COUNT(r.account_hash) AS used,
            SUM(CASE WHEN r.expires_at > ${now} THEN 1 ELSE 0 END) AS active,
            MAX(r.expires_at) AS until
       FROM codes c LEFT JOIN redemptions r ON r.code_hash = c.code_hash
      GROUP BY c.code_hash
      ORDER BY c.kind, c.created_at, c.code_hash`,
  );
  const day = (ms) => new Date(ms).toISOString().slice(0, 10);
  const table = rows.map((r) => ({
    code: known.get(r.code_hash) ?? `(not in csv) ${r.code_hash.slice(0, 8)}`,
    kind: r.kind,
    'given to': r.label ?? '',
    state:
      r.revoked_at != null
        ? `revoked ${day(r.revoked_at)}`
        : r.kind === 'school'
          ? `${r.used}/${r.max_uses} families, ${r.active} on trial now`
          : r.used === 0
            ? 'unused'
            : r.until > now
              ? `active until ${day(r.until)}`
              : `ended ${day(r.until)}`,
  }));
  return table;
}

async function label(code, name) {
  if (!code || !name) fail('usage: label <code> <name>');
  const hash = await hashOf(code);
  runFile(`UPDATE codes SET label = ${sql(name)} WHERE code_hash = '${hash}';`);
  console.log(`${code} -> ${name}`);
}

async function revoke(code) {
  if (!code) fail('usage: revoke <code>');
  const hash = await hashOf(code);
  runFile(`UPDATE codes SET revoked_at = ${Date.now()} WHERE code_hash = '${hash}' AND revoked_at IS NULL;`);
  console.log(`${code} revoked. Phones using it lose it the next time they go online.`);
}

async function hashOf(code) {
  if (!isWellFormed(normalizeCode(code))) fail(`${code} is not a Qissora code`);
  return hashCode(requirePepper(), code);
}

function pepperOrNull() {
  if (!existsSync(devVars)) return null;
  const match = readFileSync(devVars, 'utf8').match(/^VIP_PEPPER=(.+)$/m);
  return match ? match[1].trim() : null;
}

function requirePepper() {
  return pepperOrNull() ?? fail(`No VIP_PEPPER in ${devVars}. Run: node tools/codes.mjs setup`);
}

function sql(value) {
  return value == null ? 'NULL' : `'${String(value).replaceAll("'", "''")}'`;
}

function wrangler(extra) {
  if (!existsSync(wranglerBin)) fail('wrangler is not installed. Run: cd api && npm install');
  return execFileSync(
    process.execPath,
    [wranglerBin, 'd1', 'execute', 'qissora-codes', local ? '--local' : '--remote', ...extra],
    { cwd: api, encoding: 'utf8', stdio: ['inherit', 'pipe', 'inherit'] },
  );
}

function runFile(statement) {
  const file = join(tmpdir(), `codes-${process.pid}-${Date.now()}.sql`);
  writeFileSync(file, statement);
  wrangler(['--file', file, '--yes']);
}

function query(statement) {
  const out = wrangler(['--command', statement, '--json']);
  return JSON.parse(out)[0]?.results ?? [];
}

function fail(message) {
  console.error(message);
  process.exit(1);
}
