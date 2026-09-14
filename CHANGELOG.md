# Changelog

## 1.2.0

The first release the app could actually ship. Everything below was found by
reviewing the 1.1.0 tree.

### Fixed — would have blocked or broken a release

- **iOS background audio.** `Info.plist` declared no `UIBackgroundModes`, so
  iOS silenced playback the moment the app left the foreground — the app's
  core feature did not work on iOS at all.
- **Android release builds.** The project sat below Flutter's minimum Gradle
  (8.12 → 8.14.3), AGP (8.9.1 → 8.11.1) and Kotlin (2.1.0 → 2.2.20), so
  `flutter build appbundle --release` could not produce a store build.
- **The media notification had no icon.** `AudioServiceConfig` referenced
  `drawable/ic_stat_notification`, which did not exist. Added at every
  density.
- **Release builds lost their typography.** `google_fonts` fetches over the
  network and only the *debug* manifest declares `INTERNET`, so every release
  build fell back to Roboto. The faces are now bundled and runtime fetching
  is off.
- **Signing material was not git-ignored** despite a comment claiming it was.
  `*.jks`, `*.keystore` and the iOS key formats are now covered.
- **iOS, macOS, Linux and Windows still identified as `chore_tracker`** — the
  scaffold the project was created from. Bundle ids, product names and window
  titles now match Android.
- `playStory()` silently ignored `fromStart` and `startAt` when the requested
  story was already loaded.

### Security

- **The parents PIN is no longer stored in clear text.** PBKDF2-HMAC-SHA256,
  16-byte random salt per install. Installs from 1.1.0 or earlier have their
  plain-text PIN hashed on first launch and the old key deleted.
- **Wrong PIN entries are rate-limited**: four free tries, then 30s, 1m, 5m,
  15m and 30m, holding at 30m. The counter and the deadline survive a
  force-quit.
- **The lock screen no longer prints "Default PIN is 1234"** under the keypad.
  The dashboard instead flags a still-default PIN until it is changed.
- Changing the PIN now asks for it twice — a typo was unrecoverable.

### Changed

- **The "Download" action is called "Save".** Nothing was ever downloaded;
  every story's audio ships inside the app. The old label promised offline
  access that was not being provided.
- **Images are ~1 MB instead of ~10 MB.** All artwork is now right-sized WebP;
  the splash illustration alone was a 5.1 MB PNG, and the avatar shipped at
  1024×1024 to be drawn in a 40dp circle. Total assets 16 MB → 7 MB.
- The app version shown in the parents dashboard now tracks `pubspec.yaml`.

### Added

- **A test suite: 1 failing test → 108 passing**, covering all seven screens,
  PIN hashing and migration, the lockout ladder, storage, and catalogue
  integrity (every referenced audio file and cover must exist on disk).
- **CI** — formatting, analysis, tests and a release APK build, on a pinned
  Flutter version.
- **A privacy policy draft and the Play Data Safety answers**
  (`docs/PRIVACY.md`, `docs/play-data-safety.md`), both required before a
  child-directed app can be listed. The policy still needs the developer's
  name, contact address and a public URL.
- A README describing setup, the asset and font recipes, release signing,
  and the gaps that remain.

## 1.1.0 and earlier

Not documented.
