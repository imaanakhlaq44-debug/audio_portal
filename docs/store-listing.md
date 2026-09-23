# Play Store listing — draft

Copy for the Google Play listing, with Play's limits noted. **This is a draft:
read it as the developer and change anything that does not sound like you.** It
claims nothing the app does not do — every number is from the catalogue and
every promise is checked against the code — so keep it that way when editing.

Character counts were measured at the time of writing; recount after an edit.

---

## App name

Play's limit is **30 characters**.

```
Qissora — Kids Islamic Stories
```
*(30)*

Alternative if the em dash renders badly on any device:

```
Qissora: Kids Islamic Stories
```
*(29)*

---

## Short description

Play's limit is **80 characters**. This is what shows under the icon in search
results, so it has to work alone.

```
Islamic audio stories for children, in English and Urdu. No ads, ever.
```
*(70)*

Alternatives:

```
Prophet stories and good manners, narrated for children in English and Urdu.
```
*(76)*

```
11 story series in English and Urdu, for children. No ads, no tracking.
```
*(74)*

---

## Full description

Play's limit is **4000 characters**. The draft below is 2008, which leaves room
to grow. Play does not render Markdown; the headings are plain lines and the
bullets are real characters.

```
Qissora is a calm, beautiful home for Islamic and moral audio stories, made
for children and narrated by Imaan and Akhlaq.

Eleven story series, every one of them in both English and Urdu — one
hundred and sixty-four episodes in all, and more than twenty hours of
listening, so a child can hear them in the language that feels like home.

STORIES OF THE PROPHETS
Hazrat Adam, Hazrat Idris, Hazrat Nuh, Hazrat Hud and Hazrat Salih
(peace be upon them) — told gently, at a child's pace.

VALUES TO GROW UP WITH
Honesty, kindness, patience, gratitude, respect and fairness. Each series
follows children through a story where the lesson is lived, not lectured,
and closes with a small challenge to try that day.

MADE FOR LISTENING
• Series play straight through, one episode into the next, like a bedtime
  chapter book.
• Read-along words scroll with the narration, so a child can follow the text
  while they listen.
• A sleep timer that fades out gently instead of stopping mid-sentence.
• Keeps playing with the screen off, with controls on the lock screen.
• Stories are kept on the phone after the first listen, so a car journey or a
  flight needs no signal.

MADE FOR PARENTS
• No advertising of any kind. No analytics. No tracking.
• A Parents area behind a PIN, with listening stats and the child's name.
• Nothing about your child ever leaves the phone — not their name, not what
  they listened to.
• Anything that signs in or spends money asks a question a young child cannot
  answer.

TRY IT FIRST
Half of the first episode of every series plays free, so you can hear the
narration and see whether it suits your family before deciding anything.

QISSORA PREMIUM
One subscription opens all 164 episodes in both languages, for the whole
family. Monthly or yearly, through Google Play, cancellable any time from
your Google account.

Imaan & Akhlaq
Qissora is made by Imaan and Akhlaq Talks, Islamabad.

Questions or feedback: imaanakhlaq44@gmail.com
Privacy policy: https://qissora.app/app-privacy/
```

---

## Graphics still needed

Play will not accept the listing without these.

| Asset | Requirement | Status |
|---|---|---|
| App icon | 512 x 512 PNG, 32-bit | ⚠️ `site/public/brand/qissora-icon-512.png` is the right size but **24-bit** — three channels, no alpha. Play asks for 32-bit; add an alpha channel before uploading |
| Feature graphic | 1024 x 500 PNG or JPEG, no transparency | ✅ [`store/feature-graphic.png`](store/feature-graphic.png), drawn by [`tools/make_feature_graphic.mjs`](../tools/make_feature_graphic.mjs) |
| Phone screenshots | 2 to 8, 16:9 or 9:16, min 320px, max 3840px | ✅ eleven in [`store/`](store/), taken on a phone. Play takes at most eight per device type, so pick the best eight in the order below |
| Tablet screenshots | Optional, but the listing looks unfinished without them | ❌ |

The feature graphic is generated, not drawn by hand, so the copy on it cannot
drift from the catalogue:

```bash
cd site && node ../tools/make_feature_graphic.mjs
```

It needs the two brand faces — *Hey Haters* installed, and *Plus Jakarta Sans*
at `tools/fonts/` — both explained at the top of that script. Play crops this
image in some placements, so everything on it stays clear of the edges.

**Screenshots worth taking**, in the order they should appear — the first two
are what most people see:

1. Home, with the shelves of series covers.
2. A series open, showing the episode list.
3. Now Playing with the read-along words on screen.
4. The English / Urdu switch, ideally showing Urdu right-to-left.
5. The Parents area, which is the trust shot.
6. The sleep timer.

A caption band across each screenshot ("Stories of the Prophets", "Read along
as you listen") reads far better in the carousel than a bare screen. That is a
design pass, not a screen capture.

---

## Other Play Console answers

These are prepared elsewhere:

- **Data safety form** — [`play-data-safety.md`](play-data-safety.md).
- **Families / target audience** — same file. Target age groups are set there
  and need confirming against who you are actually aiming at.
- **Privacy policy URL** — `https://qissora.app/app-privacy/`.
- **Content rating questionnaire** — answered from the notes in the same file.
  The one that catches people out: the app *does* contain a digital purchase,
  and the questionnaire asks separately.
