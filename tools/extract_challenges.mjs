// Pulls the "Challenge of the Day" out of every narration script into
// tools/challenges.json, which the app reads for the Parents area.
//
//   cd site && node ../tools/extract_challenges.mjs
//
// The challenges are written in the annotated scripts, at the end of each
// episode. Most were also read aloud and so ended up in the captions, but
// not all — Kindness (English) has ten in the script and none in the
// recording. The Parents area only needs the words, so the script is the
// right source, not the captions.
//
// Scripts live outside the repo (they are git-ignored, several GB of
// narration masters sit beside them); paths come from tools/series/*.json.

import { readFileSync, readdirSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const here = dirname(fileURLToPath(import.meta.url));
const repo = resolve(here, '..');
const OUT = join(repo, 'tools', 'challenges.json');

/** `[warm] Hello` -> `Hello`. Stage directions are for the narrator. */
const undirect = (line) => line.replace(/\[[^\]]*\]/g, ' ').replace(/\s+/g, ' ').trim();

/** The heading that opens a challenge, in either language. */
const HEADING = /^(?:challenge of the day|آج کا چیلنج)\s*(\d+)?\s*[:\-–—]?\s*(.*)$/i;

/**
 * Labels inside the block. The Urdu scripts put theirs on a line alone, and
 * three different writers reached for three different words for "level up".
 */
const LABELS = [
  { key: 'mission', re: /^(?:your mission|mission)\s*[:\-–—]\s*(.*)$/i },
  { key: 'reflection', re: /^(?:quick reflection|reflection)\s*[:\-–—]\s*(.*)$/i },
  { key: 'levelUp', re: /^(?:level[\s-]*up)\s*[:\-–—]?\s*(.*)$/i },
  { key: 'levelUp', re: /^(?:اگلا (?:مرحلہ|درجہ|قدم)|ایک قدم آگے)\s*[:\-–—]?\s*(.*)$/ },
];

/**
 * What comes after the challenge at the end of a series: the overall moral
 * and the Qur'an references. Read to the listener, but not the challenge.
 */
const CLOSING = new RegExp(
  '^(' +
  [
    'کہانی کا مجموعی اخلاقی سبق', 'اسلامی حوالہ جات', 'اخلاقی سبق', 'حوالہ جات',
    'مجموعی سبق',
    // The Urdu scripts close the last episode by naming the prophet again.
    'حضرت \\S+ علیہ السلام\\s*$',
    'islamic reference', 'overall moral', 'moral of the', 'reference notes',
    'next episode',
    'end of ',
  ].join('|') +
  ')', 'i',
);

function parseEpisode(lines) {
  const at = lines.findIndex((l) => HEADING.test(l));
  if (at < 0) return null;

  const [, , rawTitle] = lines[at].match(HEADING);
  const out = { title: rawTitle.trim(), mission: '', reflection: '', levelUp: '' };

  // Everything after the heading belongs to the challenge: it closes the
  // episode. Text before the first label is the challenge itself — until
  // the series' closing sections, or a second challenge, begins.
  let current = 'mission';
  for (const line of lines.slice(at + 1)) {
    if (CLOSING.test(line) || HEADING.test(line)) break;
    let matched = false;
    for (const { key, re } of LABELS) {
      const m = line.match(re);
      if (!m) continue;
      current = key;
      const rest = (key === 'levelUp' && m[2] !== undefined ? m[2] : m[1]) ?? '';
      if (rest.trim()) out[key] += (out[key] ? ' ' : '') + rest.trim();
      matched = true;
      break;
    }
    if (!matched) out[current] += (out[current] ? ' ' : '') + line;
  }

  for (const k of ['title', 'mission', 'reflection', 'levelUp']) out[k] = out[k].trim();
  return out.title || out.mission ? out : null;
}

/** Fallback for a series whose script is not on this machine. */
function challengesFromCaptions(id) {
  const dart = readFileSync(join(repo, 'lib', 'models', 'series', `${id}.dart`), 'utf8');
  const blocks = dart.slice(dart.indexOf('episodes: [')).split(/\n {4}Story\(/).slice(1);
  return blocks.map((block) => {
    const texts = [...block.matchAll(/text:\s*'((?:[^'\\]|\\.)*)'/g)]
      .map((m) => m[1].replace(/\\(['"$])/g, '$1'));
    const at = texts.findIndex((t) => HEADING.test(t));
    return at < 0 ? null : parseEpisode(texts.slice(at));
  });
}

const result = {};
const report = [];

for (const file of readdirSync(join(repo, 'tools', 'series'))
  .filter((f) => f.endsWith('.json') && !f.includes('.cuts.'))) {
  const id = file.replace('.json', '');
  const cfg = JSON.parse(readFileSync(join(repo, 'tools', 'series', file), 'utf8'));
  const scriptPath = join(repo, cfg.script);

  if (!existsSync(scriptPath)) {
    // Gratitude's English script is not on this machine. Its challenges were
    // read aloud, so they survive in the generated captions — second best,
    // but better than a hole.
    const fromCaptions = challengesFromCaptions(id);
    result[id] = fromCaptions;
    report.push({
      id,
      status: 'ok',
      note: 'from captions (script missing)',
      found: fromCaptions.filter(Boolean).length,
      episodes: fromCaptions.length,
    });
    continue;
  }

  const marker = new RegExp(cfg.episodeMarker);
  const raw = readFileSync(scriptPath, 'utf8')
    .split(/\r?\n/)
    .slice(cfg.skipLeadingLines ?? 0);

  // Split the script into episodes on the series' own marker, which is the
  // same one gen_series.dart cuts the audio by.
  const blocks = [];
  let current = null;
  for (const line of raw) {
    const bare = undirect(line);
    if (marker.test(bare)) {
      current = [];
      blocks.push(current);
      continue;
    }
    if (current && bare) current.push(bare);
  }

  // Most scripts open with a contents list: the same episode headings again,
  // with nothing under them. Those are not episodes.
  const episodes = blocks.filter((b) => b.length > 0);

  const challenges = episodes.map(parseEpisode);
  result[id] = challenges;
  report.push({
    id,
    status: 'ok',
    found: challenges.filter(Boolean).length,
    episodes: episodes.length,
  });
}

// Episodes whose script never had a challenge, written by hand instead.
// A script always wins, so adding one there later makes the entry here
// redundant rather than conflicting.
const WRITTEN = join(repo, 'tools', 'challenges.written.json');
let filledIn = 0;
if (existsSync(WRITTEN)) {
  const written = JSON.parse(readFileSync(WRITTEN, 'utf8'));
  for (const [id, episodes] of Object.entries(written)) {
    if (id.startsWith('_') || !result[id]) continue;
    for (const [n, challenge] of Object.entries(episodes)) {
      const i = Number(n) - 1;
      if (i < 0 || i >= result[id].length || result[id][i]) continue;
      result[id][i] = { reflection: '', ...challenge, written: true };
      filledIn++;
    }
  }
}

writeFileSync(OUT, JSON.stringify(result, null, 2) + '\n');

console.log('series           episodes  challenges found');
let found = 0, eps = 0;
for (const r of report) {
  if (r.status !== 'ok') {
    console.log(`${r.id.padEnd(16)} ${r.status}: ${r.path}`);
    continue;
  }
  found += r.found;
  eps += r.episodes;
  const gap = r.episodes - r.found;
  console.log(
    `${r.id.padEnd(16)} ${String(r.episodes).padStart(8)} ${String(r.found).padStart(17)}` +
    (gap > 0 ? `   (${gap} missing)` : ''),
  );
}
console.log(
  `\n${found} from scripts + ${filledIn} written by hand = ` +
  `${found + filledIn} of ${eps} episodes`,
);
console.log(`-> ${OUT}`);
