# Imaan & Akhlaq — Kids Islamic Audio Story Portal

A Flutter audio-story app for children. Stories ship inside the app, so
everything (playback, covers, read-along captions, progress) works fully
offline. Playback continues in the background with lock-screen and
notification controls.

## Features

- **6 narrated stories** across Prophets, Animals, Nature, Bedtime and Moral
  categories, with a rotating "Story of the Day".
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
  models/                    Story, StoryCategory, the story catalogue
  screens/                   splash, home, library, category, now playing,
                             parents lock + dashboard
  services/
    audio_player_service.dart  app-facing playback controller (ChangeNotifier)
    story_audio_handler.dart   just_audio <-> audio_service bridge
    storage_service.dart       Hive-backed local storage
    theme_controller.dart      light/dark/system theme
  theme/app_theme.dart       colour tokens + typography
  widgets/                   mini player, story tile, category card, ...
assets/
  audio/ covers/ images/ icon/   bundled story media
  google_fonts/                  bundled Plus Jakarta Sans + Bricolage
                                 Grotesque (see "Fonts" below)
```

## Adding a story

1. Drop the MP3 in `assets/audio/` and the cover PNG in `assets/covers/`.
2. Add a `Story(...)` entry to `lib/models/story_data.dart`, including its
   caption lines (`_caps([[start, end, 'text'], ...])`, seconds as doubles).
3. `flutter test` — `test/story_data_test.dart` verifies that every referenced
   asset exists and that captions are ordered and non-overlapping.

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

## Known gaps

Tracked, not yet done:

- The "Save" action is a bookmark, not an actual download (all audio is
  already bundled).
- English only — no Urdu/Arabic localisation or RTL layout yet.
- Progress and favourites are device-local; there is no backup or sync.
- No crash reporting / analytics.
