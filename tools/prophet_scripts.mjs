// Pulls the narration scripts for the new prophet series out of the Gemini
// TTS .docx files and writes the annotated_script.txt that
// tools/gen_series.dart reads.
//
//   node tools/prophet_scripts.mjs
//
// The .docx are what was fed to the TTS, so they are the spoken words
// exactly. Two things in them are not spoken and must not reach a caption:
// the emotion tags ([calm], [whispers]) that gen_series.dart already strips,
// and - in the Urdu files only - the translator's own note above the title,
// which is dropped here by starting at the series heading.

import { readFileSync, writeFileSync } from 'node:fs';
import { execFileSync } from 'node:child_process';
import { join } from 'node:path';

const root = join(import.meta.dirname, '..', 'Prophet_Stories_Audio');

/** The text of word/document.xml, one line per paragraph. */
function docxText(path) {
  const xml = execFileSync(
    'powershell',
    [
      '-NoProfile',
      '-Command',
      `Add-Type -AssemblyName System.IO.Compression.FileSystem;` +
        `$zip=[System.IO.Compression.ZipFile]::OpenRead('${path}');` +
        `$e=$zip.Entries|Where-Object{$_.FullName -eq 'word/document.xml'};` +
        `$r=New-Object System.IO.StreamReader($e.Open());` +
        `[Console]::OutputEncoding=[Text.Encoding]::UTF8;` +
        `Write-Output $r.ReadToEnd();$r.Close();$zip.Dispose()`,
    ],
    { encoding: 'utf8', maxBuffer: 256 * 1024 * 1024 },
  );
  return xml
    .replace(/<\/w:p>/g, '\n')
    .replace(/<[^>]+>/g, '')
    .replace(/&amp;/g, '&')
    .replace(/&lt;/g, '<')
    .replace(/&gt;/g, '>')
    .replace(/&quot;/g, '"')
    .replace(/&apos;/g, "'");
}

const series = [
  {
    dir: 'Hazrat_Ibrahim_AS_English',
    docx: 'Ibrahim_AS_English_Gemini_TTS_Tagged.docx',
    startsAt: /^Hazrat Ibrahim \(A\.S\.\)/,
    episodes: 11,
    marker: /^Episode \d+:/,
  },
  {
    dir: 'Hazrat_Lut_AS_English',
    docx: 'Hazrat_Lut_AS_English_Gemini_TTS_Tagged.docx',
    startsAt: /^Hazrat Lut \(A\.S\.\)/,
    episodes: 6,
    marker: /^Episode \d+:/,
  },
  {
    dir: 'Hazrat_Ibrahim_AS_Urdu',
    docx: 'Ibrahim_AS_Urdu_Gemini_TTS_Tagged.docx',
    startsAt: /^حضرت ابراہیم/,
    episodes: 11,
    marker: /^قسط \S+/,
  },
  {
    dir: 'Hazrat_Lut_AS_Urdu',
    docx: 'Hazrat_Lut_AS_Urdu_Gemini_TTS_Tagged.docx',
    startsAt: /^حضرت لوط/,
    episodes: 6,
    marker: /^قسط \S+/,
  },
];

for (const s of series) {
  const lines = docxText(join(root, s.dir, s.docx))
    .split('\n')
    .map((l) => l.replace(/ /g, ' ').trim());

  const start = lines.findIndex((l) => s.startsAt.test(l));
  if (start < 0) throw new Error(`${s.dir}: no series heading found`);

  const body = lines.slice(start).filter((l) => l !== '');
  const found = body.filter((l) => s.marker.test(l)).length;
  if (found !== s.episodes) {
    throw new Error(`${s.dir}: ${found} episode markers, expected ${s.episodes}`);
  }

  const out = join(root, s.dir, 'annotated_script.txt');
  writeFileSync(out, body.join('\n') + '\n');
  console.log(
    `${s.dir.padEnd(26)} ${String(body.length).padStart(5)} lines, ` +
      `${found} episodes, dropped ${start} lines above the title`,
  );
}
