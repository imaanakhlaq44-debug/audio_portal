// Draws the 1024x500 feature graphic Google Play shows at the top of the
// store listing, into docs/store/feature-graphic.png.
//
//   cd site && node ../tools/make_feature_graphic.mjs
//
// Run it from site/ so it can borrow that project's `sharp`; the app itself
// has no image tooling and does not need any.
//
// Two fonts, the ones in the brand guidelines:
//
//   Hey Haters         headings. Licensed, so not in this repo — install it
//                      (it is picked up from the Windows font folders).
//   Plus Jakarta Sans  body. Open Font License. Put the variable TTF at
//                      tools/fonts/PlusJakartaSans.ttf:
//                      https://github.com/google/fonts/tree/main/ofl/plusjakartasans
//
// Both are found through a fontconfig file this script writes itself, so
// nothing has to be installed system-wide except Hey Haters.
//
// Play's rules for this image: exactly 1024x500, PNG or JPEG, and no
// transparency. It is also cropped in some placements, so nothing that
// matters goes near an edge.

import { createRequire } from 'node:module';
import { mkdirSync, writeFileSync, existsSync } from 'node:fs';
import { dirname, join, resolve } from 'node:path';
import { fileURLToPath } from 'node:url';
import { tmpdir } from 'node:os';
import { spawnSync } from 'node:child_process';

const here = dirname(fileURLToPath(import.meta.url));
const repo = resolve(here, '..');

// fontconfig has to be told about tools/fonts and about the per-user font
// folder, which is where a font installed "for me only" on Windows lands.
//
// Setting process.env.FONTCONFIG_PATH here does not work: sharp's native
// side reads the variable out of the real environment as it loads, and
// never sees a change made from JavaScript. So write the config, then start
// again in a child that has the variable set for real.
if (!process.env.QISSORA_FONTCONFIG) {
  const dir = join(tmpdir(), 'qissora-fontconfig');
  mkdirSync(join(dir, 'cache'), { recursive: true });
  const local = join(repo, 'tools', 'fonts');
  const userFonts = process.env.LOCALAPPDATA
    ? join(process.env.LOCALAPPDATA, 'Microsoft', 'Windows', 'Fonts')
    : '';
  const slash = (p) => p.replace(/\\/g, '/');

  writeFileSync(join(dir, 'fonts.conf'), `<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "fonts.dtd">
<fontconfig>
  <dir>${slash(local)}</dir>
  ${userFonts ? `<dir>${slash(userFonts)}</dir>` : ''}
  <dir>WINDOWSFONTDIR</dir>
  <dir prefix="xdg">fonts</dir>
  <cachedir>${slash(join(dir, 'cache'))}</cachedir>
</fontconfig>
`);

  if (!existsSync(join(local, 'PlusJakartaSans.ttf'))) {
    console.warn(
      'tools/fonts/PlusJakartaSans.ttf is missing — the body text will fall\n' +
      'back to a serif. See the note at the top of this file.',
    );
  }

  const child = spawnSync(
    process.execPath,
    [fileURLToPath(import.meta.url), ...process.argv.slice(2)],
    {
      stdio: 'inherit',
      env: { ...process.env, FONTCONFIG_PATH: dir, QISSORA_FONTCONFIG: '1' },
    },
  );
  process.exit(child.status ?? 1);
}

const sharp = createRequire(join(repo, 'site', 'package.json'))('sharp');

const OUT = join(repo, 'docs', 'store', 'feature-graphic.png');
const W = 1024, H = 500;

// The brand palette, straight from lib/theme/app_theme.dart.
const PINK = '#ca2962', PINK_DEEP = '#a8014a', ORANGE = '#dd7a10';
const NAVY = '#192f52', CREAM = '#fff8f7', INK_SOFT = '#594045';
const PINK_TINT = '#ffd9df', PEACH_TINT = '#ffdcc3', SKY_TINT = '#d7e3ff';

const DISPLAY = 'Hey Haters';
const BODY = 'Plus Jakarta Sans';

/** Cream ground with the soft painterly shapes the covers are painted on. */
const background = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}">
  <defs>
    <radialGradient id="warm" cx="15%" cy="15%" r="95%">
      <stop offset="0%" stop-color="#fffdfc"/>
      <stop offset="100%" stop-color="${CREAM}"/>
    </radialGradient>
    <linearGradient id="ribbon" x1="0" y1="0" x2="1" y2="0">
      <stop offset="0%" stop-color="${PINK}"/>
      <stop offset="55%" stop-color="${ORANGE}"/>
      <stop offset="100%" stop-color="${PINK}"/>
    </linearGradient>
  </defs>
  <rect width="${W}" height="${H}" fill="url(#warm)"/>

  <circle cx="60"  cy="470" r="150" fill="${PINK_TINT}" opacity="0.55"/>
  <circle cx="175" cy="410" r="46"  fill="${PEACH_TINT}" opacity="0.7"/>
  <circle cx="930" cy="40"  r="120" fill="${SKY_TINT}" opacity="0.45"/>
  <circle cx="620" cy="30"  r="40"  fill="${PEACH_TINT}" opacity="0.55"/>

  <rect x="0" y="0" width="${W}" height="8" fill="url(#ribbon)"/>
</svg>`);

/** One cover, rounded and tilted, the way the shelves look in the app. */
async function coverCard(name, size, angle) {
  const rounded = Buffer.from(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}">
      <rect width="${size}" height="${size}" rx="34" ry="34" fill="#fff"/>
    </svg>`,
  );
  const art = await sharp(join(repo, 'site', 'public', 'covers', `${name}.webp`))
    .resize(size, size, { fit: 'cover' })
    .composite([{ input: rounded, blend: 'dest-in' }])
    .png()
    .toBuffer();

  // A pale rim so one cover reads apart from the next where they overlap.
  const rim = Buffer.from(
    `<svg xmlns="http://www.w3.org/2000/svg" width="${size}" height="${size}">
      <rect x="2" y="2" width="${size - 4}" height="${size - 4}" rx="32" ry="32"
        fill="none" stroke="#ffffff" stroke-width="5"/>
    </svg>`,
  );

  return sharp(art)
    .composite([{ input: rim }])
    .rotate(angle, { background: { r: 0, g: 0, b: 0, alpha: 0 } })
    .png()
    .toBuffer();
}

const text = Buffer.from(`<svg xmlns="http://www.w3.org/2000/svg" width="${W}" height="${H}">
  <rect x="64" y="60" width="296" height="38" rx="19" fill="${PINK_TINT}"/>
  <text x="84" y="85" font-family="${BODY}" font-size="15" font-weight="800"
    letter-spacing="2.2" fill="${PINK_DEEP}">IMAAN &amp; AKHLAQ PRESENT</text>

  <text x="64" y="176" font-family="${DISPLAY}" font-size="52" fill="${NAVY}">Every story carries</text>
  <text x="64" y="238" font-family="${DISPLAY}" font-size="52" fill="${PINK}">a beautiful lesson</text>

  <text x="66" y="290" font-family="${BODY}" font-size="21" font-weight="500" fill="${INK_SOFT}">
    Islamic &amp; moral audio stories for children,
  </text>
  <text x="66" y="320" font-family="${BODY}" font-size="21" font-weight="500" fill="${INK_SOFT}">
    narrated in English and Urdu.
  </text>

  <!-- Hours, not series. There are 22 series records but only 11 stories,
       each told in English and Urdu; "22 series" next to "both languages"
       reads as 44 and sets parents up to feel short-changed. -->
  <rect x="64"  y="360" width="132" height="42" rx="21" fill="#ffffff" stroke="${PINK_TINT}" stroke-width="2"/>
  <text x="130" y="387" font-family="${BODY}" font-size="17" font-weight="800"
    text-anchor="middle" fill="${NAVY}">22 hours</text>

  <rect x="210" y="360" width="160" height="42" rx="21" fill="#ffffff" stroke="${PINK_TINT}" stroke-width="2"/>
  <text x="290" y="387" font-family="${BODY}" font-size="17" font-weight="800"
    text-anchor="middle" fill="${NAVY}">164 episodes</text>

  <rect x="384" y="360" width="152" height="42" rx="21" fill="${NAVY}"/>
  <text x="460" y="387" font-family="${BODY}" font-size="17" font-weight="800"
    text-anchor="middle" fill="#ffffff">No ads, ever</text>
</svg>`);

const SIZE = 190;
const cards = [
  { name: 'nuh', angle: -7, left: 590, top: 168 },
  { name: 'kindness', angle: 4, left: 686, top: 140 },
  { name: 'adam', angle: -3, left: 782, top: 172 },
];

const layers = [];
for (const c of cards) {
  const card = await coverCard(c.name, SIZE, c.angle);
  // Rotating grows the canvas, so the shadow has to match what came back.
  const { width: cw, height: ch } = await sharp(card).metadata();
  const shadow = await sharp(card)
    .composite([{
      input: Buffer.from(
        `<svg xmlns="http://www.w3.org/2000/svg" width="${cw}" height="${ch}">
          <rect width="${cw}" height="${ch}" fill="${NAVY}"/>
        </svg>`,
      ),
      blend: 'in',
    }])
    .blur(12)
    .png()
    .toBuffer();

  layers.push({ input: shadow, left: c.left + 4, top: c.top + 12, opacity: 0.18 });
  layers.push({ input: card, left: c.left, top: c.top });
}

mkdirSync(dirname(OUT), { recursive: true });
await sharp(background)
  .composite([...layers, { input: text }])
  .flatten({ background: CREAM })
  // Play wants no transparency, so the alpha channel goes rather than
  // just being filled in.
  .removeAlpha()
  .png({ compressionLevel: 9 })
  .toFile(OUT);

const meta = await sharp(OUT).metadata();
console.log(`wrote ${OUT} — ${meta.width}x${meta.height}, ` +
  `${meta.channels} channels, alpha: ${meta.hasAlpha}`);
