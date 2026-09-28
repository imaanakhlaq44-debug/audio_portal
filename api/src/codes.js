// Code format and hashing, shared by the Worker and tools/codes.mjs so both
// agree on what a code hashes to.

// No 0/O, 1/I/L: codes are read out and typed by hand.
export const ALPHABET = '23456789ABCDEFGHJKMNPQRSTUVWXYZ';
const BODY_LENGTH = 8;

/** The first two letters say what a code is for. */
export const PREFIX = { vip: 'QV', school: 'QS' };

/** Uppercases and drops dashes and spaces: "qv-7k3m 9xpa" -> "QV7K3M9XPA". */
export function normalizeCode(input) {
  return String(input)
    .toUpperCase()
    .replace(/[^A-Z0-9]/g, '');
}

export function isWellFormed(code) {
  return new RegExp(`^(QV|QS)[${ALPHABET}]{${BODY_LENGTH}}$`).test(code);
}

/** A new code of [kind], as printed: "QV-7K3M-9XPA". */
export function newCode(kind = 'vip') {
  const bytes = crypto.getRandomValues(new Uint8Array(BODY_LENGTH));
  // 256 is not a multiple of the alphabet's length, so the modulo leans very
  // slightly towards the first few characters. At 8 characters that costs a
  // fraction of a bit, which does not matter behind a per-account rate limit.
  const body = [...bytes].map((b) => ALPHABET[b % ALPHABET.length]).join('');
  return `${PREFIX[kind]}-${body.slice(0, 4)}-${body.slice(4)}`;
}

export async function sha256Hex(text) {
  const digest = await crypto.subtle.digest(
    'SHA-256',
    new TextEncoder().encode(text),
  );
  return [...new Uint8Array(digest)]
    .map((b) => b.toString(16).padStart(2, '0'))
    .join('');
}

export const hashCode = (pepper, code) =>
  sha256Hex(`${pepper}:code:${normalizeCode(code)}`);

export const hashAccount = (pepper, googleSub) =>
  sha256Hex(`${pepper}:account:${googleSub}`);
