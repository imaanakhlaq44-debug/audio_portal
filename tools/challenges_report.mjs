// Writes docs/challenges.md from tools/challenges.json: every episode, the
// challenge that was found, and a blank where one still has to be written.
//
//   node tools/challenges_report.mjs

import { readFileSync, writeFileSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';

const repo = resolve(dirname(fileURLToPath(import.meta.url)), '..');
const data = JSON.parse(readFileSync(join(repo, 'tools', 'challenges.json'), 'utf8'));

const web = JSON.parse(
  readFileSync(join(repo, 'site', 'src', 'data', 'stories.generated.ts'), 'utf8')
    .replace(/^[\s\S]*?= \[/, '[').trimEnd().replace(/;$/, ''),
);
const series = Object.fromEntries(web.map((s) => [s.id, s]));

const missing = [];
const body = [];

for (const [id, list] of Object.entries(data)) {
  const s = series[id];
  body.push(`## ${id} — ${s?.title ?? ''}`, '');
  list.forEach((c, i) => {
    const epTitle = s?.episodes[i]?.title ?? `Episode ${i + 1}`;
    body.push(`### ${epTitle}`);
    if (!c) {
      missing.push({ id, n: i + 1, title: s?.title ?? id, epTitle });
      body.push('title:', 'mission:', 'levelUp:', '  <!-- TO WRITE -->', '');
      return;
    }
    body.push(`title: ${c.title}`);
    body.push(`mission: ${c.mission}`);
    if (c.reflection) body.push(`reflection: ${c.reflection}`);
    body.push(`levelUp: ${c.levelUp}`, '');
  });
}

const total = Object.values(data).flat().length;
const found = total - missing.length;

const head = [
  '# Challenge of the Day',
  '',
  `One per episode, shown to the parent in the Parents area. ${found} of ${total}`,
  'were taken straight out of the narration scripts by',
  '`tools/extract_challenges.mjs`; the rest are blank and need writing.',
  '',
  'Edit anything here, then re-run the extractor only if you change a *script* —',
  'edits made in this file are not read back. The app reads',
  '`tools/challenges.json`.',
  '',
  '- **title** — a short name, a few words.',
  '- **mission** — the challenge itself.',
  '- **reflection** — the question to ask afterwards. Optional; only Kindness has these.',
  '- **levelUp** — the harder version.',
  '',
  '## Still to write',
  '',
];

if (missing.length === 0) {
  head.push('Nothing — every episode has one.', '');
} else {
  head.push('| Series | Episode | |', '|---|---|---|');
  for (const m of missing) head.push(`| ${m.id} | ${m.n} | ${m.epTitle} |`);
  head.push('', `**${missing.length} to write.**`, '');
}
head.push('---', '');

writeFileSync(join(repo, 'docs', 'challenges.md'), head.concat(body).join('\n'));
console.log(`${found} of ${total} episodes have a challenge; ${missing.length} to write`);
for (const m of missing) console.log(`  ${m.id} ep${m.n} — ${m.epTitle}`);
