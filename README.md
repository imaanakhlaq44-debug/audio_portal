# Qissora — Kids Islamic Audio Stories

A Flutter audio-story app for children. Stories stream from
`audio.qissora.app` and are cached on the phone at first play, so a story
heard once works offline afterwards; covers, captions and progress are always
local. Playback continues in the background with lock-screen and notification
controls.

There is a website too, in [`site/`](site/) — see its
[README](site/README.md).

## Features

- **22 series, 164 episodes**, in English and Urdu, across Prophets and Moral
  Stories, with a rotating featured series per language.
- **Series play as playlists** — finishing an episode starts the next, keeps a
  running sleep timer, and stops at the end of the series.
- **Qissora Premium** — episode 1 of every series plays free up to its halfway
  point; the rest unlocks with a Google Play subscription. A grown-up check
  stands in front of anything that signs in or spends money.
- **Background audio** — keeps playing when the screen is locked or the app is
  backgrounded; media notification, headphone and Bluetooth controls, pauses
  on calls and when headphones are unplugged.
- **Continue listening** — position is flushed to disk every 5 seconds and on
  every pause/seek, so a story resumes exactly where the child left off even
  after the app is killed.
- **Sleep timer** with a gentle 30-second volume fade-out.
- **Read-along captions** synced to the audio, plus a full-story view.
- **Favorites & saved list**, search, light/dark themes.
- **Parents area** behind a PIN: change PIN, set the child's name, listening
  stats, and reset history.

## Getting started

Requires the Flutter SDK matching `environment.sdk` in
[`pubspec.yaml`](pubspec.yaml) (Dart ^3.9.2).

```bash
flutter pub get
flutter run
```

Checks — CI runs exactly these, and rejects a diff after `dart format`:

```bash
dart format lib test
flutter analyze
flutter test
```

CI pins **Flutter 3.44.3** (`.github/workflows/ci.yml`). `dart format` changes
its output between SDK releases, so an unpinned runner rejects trees that a
developer's own formatter considers clean. Use the same version locally, and
bump the pin as a deliberate change when adopting a newer Flutter — the
trade-off is that CI no longer warns you when a new stable release breaks the
build, so check that when you bump.

## Project layout

```
lib/
  main.dart                  app entry, providers, bottom-nav shell
  audio_config.dart          where story audio is streamed from
  models/                    Story, Series, categories, the catalogue
    series/                  one generated file per series (22 of them)
  screens/                   splash, home, library, category, series,
                             now playing, about, FAQ,
                             parents lock + dashboard
  services/
    audio_player_service.dart  app-facing playback controller (ChangeNotifier)
    story_audio_handler.dart   just_audio <-> audio_service bridge
    premium_service.dart       Play Billing, Google sign-in, who may hear what
    storage_service.dart       Hive-backed local storage
    theme_controller.dart      light/dark/system theme
  theme/app_theme.dart       colour tokens + typography
  widgets/                   mini player, story tile, category card, ...
assets/
  audio/                         cut episodes — git-ignored, uploaded to R2
                                 rather than bundled (see "Adding a series")
  covers/ images/ icon/          bundled artwork
  google_fonts/                  bundled Plus Jakarta Sans + Bricolage
                                 Grotesque (see "Fonts" below)
site/                        the qissora.app website (Next.js)
tools/                       series generator, cover and upload scripts
```

## Adding a series

Series are generated, not hand-written. Each one is a config in
[`tools/series/`](tools/series/) naming its narration script, the master
recording, a whisper transcript of that recording, and where to write the
Dart.

1. Record the series as one master, and transcribe it once with ffmpeg's
   whisper filter — the command is in the header of
   [`tools/gen_series.dart`](tools/gen_series.dart).
2. Write the config, copying a neighbour in `tools/series/`. Put the cover in
   `assets/covers/` as **1024x1024 WebP** (`cwebp -q 88 -m 6`, see "Image
   assets" below); `tools/make_covers.ps1` does this from `covers/`.
3. `dart run tools/gen_series.dart tools/series/<id>.json --cut`. This cuts
   the master into per-episode audio under `assets/audio/`, aligns every
   script line to when it was actually spoken, and writes
   `lib/models/series/<id>.dart`.
4. Register the series in `lib/models/series.dart`, and write its
   introduction in `lib/models/series_intros.dart`.
5. `dart run tools/upload_audio.ps1` — or the PowerShell script directly — to
   put the episodes in R2 under the same paths the app streams from.
6. `flutter test` — `test/story_data_test.dart` checks ids, covers, stream
   URLs, and that captions are ordered and non-overlapping.

## Fonts

Typography uses Plus Jakarta Sans and Bricolage Grotesque. The static faces
are **bundled** in `assets/google_fonts/` and runtime fetching is switched off
in `main()` (`GoogleFonts.config.allowRuntimeFetching = false`).

This is deliberate: release builds hold no `INTERNET` permission, so a
network-fetched font would silently fall back to Roboto. Both families are
licensed under the SIL Open Font License — see
[`assets/google_fonts/OFL.txt`](assets/google_fonts/OFL.txt), which is also
registered with Flutter's `LicenseRegistry` and shown in the app's licence
page.

## Android release build

Release signing reads `android/key.properties`, which is git-ignored and
therefore not in this repo. Without it the build falls back to the debug key,
so a fresh clone still builds.

Create `android/key.properties`:

```properties
storePassword=<password>
keyPassword=<password>
keyAlias=upload
storeFile=<path to the .jks, relative to android/app/>
```

Then:

```bash
flutter build appbundle --release
```

Release builds run R8 with `android/app/proguard-rules.pro` (keeps
`audio_service` / `just_audio` classes).

> **Never commit** `key.properties`, `*.jks` or `*.keystore`. They are listed
> in `.gitignore`; if one is ever committed, rotate the key.

## Parents PIN

The PIN is stored as PBKDF2-HMAC-SHA256 (50,000 iterations, 16-byte random
salt per install) — see `lib/services/pin_service.dart`. It is never written
in clear text. Installs upgrading from 1.1.0 or earlier have their plain-text
PIN hashed on first launch and the old key deleted.

Wrong entries are rate-limited on the device: four free tries, then lockouts
of 30s, 1m, 5m, 15m and 30m, holding at 30m. Both the counter and the
deadline are persisted, so force-quitting the app does not reset them.

**What this buys, and what it does not.** A 4-digit PIN is 10,000
candidates, so anyone who can copy the Hive file off the device and grind it
offline gets in regardless of the iteration count. Hashing keeps the PIN out
of clear text in files that land in device backups; the lockout is what stops
a child working through the keypad. Treat the parents area as a speed bump,
not a vault.

## Image assets

Every bundled image is WebP, sized to what the UI actually renders:

| asset | size | encoded with |
|---|---|---|
| `covers/*.webp` | 1024x1024 | `cwebp -q 88 -m 6` |
| `images/splash_illustration.webp` | 1536x2752 | `cwebp -q 85 -m 6` |
| `images/child_avatar.webp` | 160x160 (drawn at 40dp) | `cwebp -q 85 -m 6` |
| `icon/app_icon.webp` | 192x192 | `cwebp -lossless -m 6` |

Keep new artwork to the same recipe. Two things to watch for:

- **Match the file extension to the real format.** The covers were
  previously JPEG data named `.png`, which works (decoders sniff content)
  but misleads every human and tool that looks at the repo.
- **Size the asset to its widest use, not to the source file.** The avatar
  shipped at 1024x1024 for a 40dp circle: 415 KB on disk and ~4 MB of image
  cache to draw a thumbnail.

## Platform notes

- **Android** — `MainActivity` extends `AudioServiceActivity`; the foreground
  media service, media-button receiver and `FOREGROUND_SERVICE_MEDIA_PLAYBACK`
  / `POST_NOTIFICATIONS` permissions are declared in the manifest. The
  notification small icon is `res/drawable-*/ic_stat_notification.png`.
- **iOS** — `UIBackgroundModes: audio` in `Info.plist` is what keeps playback
  alive once the app leaves the foreground. Removing it breaks the core
  feature.
- **Web / desktop** — the targets build, but the UI is designed for portrait
  phones and `audio_service` background features are limited there.

## Store listing

- [`docs/PRIVACY.md`](docs/PRIVACY.md) — privacy policy **draft**. Fill in the
  `[[...]]` placeholders, publish it at a public URL, and link that URL from
  the Play Console and App Store listings. A reachable privacy policy is
  mandatory for a child-directed app.
- [`docs/play-data-safety.md`](docs/play-data-safety.md) — the Data safety and
  Families answers, each with the reason behind it, plus the list of changes
  that would invalidate them.

## Releasing

`pubspec.yaml` holds the version the build uses; `lib/app_info.dart` holds
the one the parents dashboard shows. Bump both — `test/app_info_test.dart`
fails if they drift — and add a [`CHANGELOG.md`](CHANGELOG.md) entry.

## Known gaps

Tracked, not yet done:

- **Not published yet.** No Play Store listing exists, so every "get the app"
  button on the website reads "coming soon" — flip `appStoreLinks.published`
  in `site/src/lib/site.ts` on launch day. Still missing for submission:
  screenshots, a 1024x500 feature graphic, and the store descriptions.
- **Ads are planned for 1.4.0, and deliberately not in 1.3.0.** Free listeners
  would get them; Premium stays ad-free, which is what the paywall's "No ads,
  ever" line already promises. Wanted: a banner on the browse screens, an
  interstitial at the end of an episode, and an opt-in rewarded ad in the
  Parents area. None of it is a small change. The app is child-directed, so it
  needs a Play-**certified** ads SDK with child-directed treatment — no
  personalised ads, content rating G — the Play Ads declaration flipped to Yes,
  the Data safety answers redone (an ads SDK collects device identifiers, which
  turns several of them), and the "no ads" claim rewritten in the thirteen
  places it appears: `faq_screen.dart`, `paywall_sheet.dart`, `docs/PRIVACY.md`
  and the site's copy of it, `docs/store-listing.md`,
  `docs/play-data-safety.md`, `docs/index.md`, four website components, and the
  feature graphic. Two things to design rather than bolt on: the end-of-episode
  interstitial cuts across series auto-continuing into the next episode, which
  is a headline feature and a listing claim; and full-screen ads shown to
  under-8s carry extra Play restrictions.
- **Premium is Android only.** `PremiumService` is built on Play Billing;
  there is no StoreKit path, so an iOS build would ship with nothing to buy.
- The "Save" action is a bookmark, not a download. Audio is cached when a
  story plays, so there is no way to fetch a series ahead of a journey.
- The catalogue is compiled in, so a new series needs an app update even
  though its audio is served remotely.
- Progress and favourites are device-local; there is no backup or sync.
- No crash reporting / analytics. (Adding any would change the store
  data-safety answers — see `docs/play-data-safety.md`.)
- `shared_preferences` and `intl` are declared in `pubspec.yaml` but never
  imported.
