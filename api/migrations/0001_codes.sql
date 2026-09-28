-- Codes that open Premium for free, given by hand:
--   vip     one family, for a year
--   school  one code for a whole school, a month for each family
--
-- Only peppered hashes of codes and of Google account IDs are stored, so
-- these tables on their own give nobody a working code or an identity.
CREATE TABLE codes (
  code_hash  TEXT PRIMARY KEY,
  kind       TEXT NOT NULL CHECK (kind IN ('vip', 'school')),
  -- Who the code was given to. A note for us; the app never sees it.
  label      TEXT,
  -- How long Premium lasts for each family, from the day they redeem it.
  days       INTEGER NOT NULL,
  -- How many Google accounts may redeem it.
  max_uses   INTEGER NOT NULL,
  created_at INTEGER NOT NULL,
  -- Switches the code off, and every redemption of it with it.
  revoked_at INTEGER
);

-- One row per family per code.
CREATE TABLE redemptions (
  code_hash    TEXT NOT NULL REFERENCES codes (code_hash),
  account_hash TEXT NOT NULL,
  kind         TEXT NOT NULL,
  redeemed_at  INTEGER NOT NULL,
  expires_at   INTEGER NOT NULL,
  -- Random, handed to the app so it can ask later whether its code still
  -- stands without signing the parent in again.
  ticket       TEXT NOT NULL UNIQUE,
  PRIMARY KEY (code_hash, account_hash)
);

CREATE INDEX redemptions_account ON redemptions (account_hash);

-- Wrong codes per account, to stop anyone working through guesses.
CREATE TABLE redeem_failures (
  account_hash TEXT NOT NULL,
  at           INTEGER NOT NULL
);

CREATE INDEX redeem_failures_account ON redeem_failures (account_hash, at);
