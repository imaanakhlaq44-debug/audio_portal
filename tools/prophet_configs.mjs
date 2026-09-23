// Writes the gen_series.dart config and cuts for the two new prophet series.
//
//   node tools/prophet_configs.mjs
//
// These two were delivered already split into per-episode files, unlike the
// earlier series which are one master that the pipeline finds the cuts in by
// ear. The cuts are therefore known exactly - each episode starts where the
// ones before it end - so they are written here and gen_series.dart is run
// with --reuse-cuts rather than being asked to listen for episode titles it
// would never hear: these recordings do not speak them.

import { writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { join } from 'node:path';

const repo = join(import.meta.dirname, '..');

const seconds = (file) =>
  Number(
    execFileSync(
      'ffprobe',
      ['-v', 'error', '-show_entries', 'format=duration', '-of', 'csv=p=0', file],
      { encoding: 'utf8' },
    ).trim(),
  );

const series = [
  {
    id: 'ibrahim_en',
    dir: 'Hazrat_Ibrahim_AS_English',
    prefix: 'Ibrahim_EN_Ep',
    episodes: 11,
    title: 'Hazrat Ibrahim (A.S.)',
    language: 'english',
    moral: 'searching for the truth and trusting Allah with everything',
    cover: 'ibrahim',
    marker: '^Episode (\\d+): (.+)$',
    variable: 'ibrahimEnglish',
  },
  {
    id: 'ibrahim_ur',
    dir: 'Hazrat_Ibrahim_AS_Urdu',
    prefix: 'Ibrahim_UR_Ep',
    episodes: 11,
    title: 'حضرت ابراہیم علیہ السلام',
    language: 'urdu',
    moral: 'حضرت ابراہیم علیہ السلام',
    cover: 'ibrahim',
    marker: '^قسط (\\S+)$',
    variable: 'ibrahimUrdu',
  },
  {
    id: 'lut_en',
    dir: 'Hazrat_Lut_AS_English',
    prefix: 'Lut_EN_Ep',
    episodes: 6,
    title: 'Hazrat Lut (A.S.)',
    language: 'english',
    moral: 'haya, self-control and staying clean when wrong feels normal',
    cover: 'lut',
    marker: '^Episode (\\d+): (.+)$',
    variable: 'lutEnglish',
  },
  {
    id: 'lut_ur',
    dir: 'Hazrat_Lut_AS_Urdu',
    prefix: 'Lut_UR_Ep',
    episodes: 6,
    title: 'حضرت لوط علیہ السلام',
    language: 'urdu',
    moral: 'حضرت لوط علیہ السلام',
    cover: 'lut',
    marker: '^قسط (\\S+): (.+)$',
    variable: 'lutUrdu',
  },
];

for (const s of series) {
  const folder = join(repo, 'Prophet_Stories_Audio', s.dir);
  const lang = s.language === 'urdu' ? 'ur' : 'en';
  const full = join(
    folder,
    `${s.dir}_Full_Audiobook.mp3`.replace('Ibrahim_AS_', 'Ibrahim_AS_'),
  );

  // Each episode begins where the ones before it end, because the audiobook
  // is those files joined in order (their concat_list.txt).
  const cuts = [];
  let at = 0;
  for (let i = 1; i <= s.episodes; i++) {
    const file = join(folder, `${s.prefix}${String(i).padStart(2, '0')}.mp3`);
    const end = at + seconds(file);
    cuts.push([Number(at.toFixed(3)), Number(end.toFixed(3))]);
    at = end;
  }

  const drift = seconds(full) - at;
  if (Math.abs(drift) > 2) {
    throw new Error(
      `${s.id}: episodes total ${at.toFixed(1)}s but the audiobook is ` +
        `${seconds(full).toFixed(1)}s - they are not the same recording`,
    );
  }

  const config = {
    id: s.id,
    series: s.title,
    language: s.language,
    moral: s.moral,
    category: 'prophets',
    narrator: 'Imaan & Akhlaq',
    cover: `assets/covers/${s.cover}.webp`,
    script: `Prophet_Stories_Audio/${s.dir}/annotated_script.txt`,
    skipLeadingLines: 1,
    ...(s.language === 'urdu' ? { splitSentences: true } : {}),
    episodeMarker: s.marker,
    master: `Prophet_Stories_Audio/${s.dir}/${s.dir}_Full_Audiobook.mp3`,
    transcript: `Prophet_Stories_Audio/${s.dir}/transcript.srt`,
    audioDir: `assets/audio/${lang}/${s.cover}`,
    output: `lib/models/series/${s.id}.dart`,
    variable: s.variable,
  };

  writeFileSync(
    join(repo, 'tools', 'series', `${s.id}.json`),
    JSON.stringify(config, null, 2) + '\n',
  );
  writeFileSync(
    join(repo, 'tools', 'series', `${s.id}.cuts.json`),
    JSON.stringify(cuts) + '\n',
  );
  console.log(
    `${s.id.padEnd(12)} ${s.episodes} episodes, ${(at / 60).toFixed(1)} min, ` +
      `drift ${drift.toFixed(2)}s`,
  );
}
