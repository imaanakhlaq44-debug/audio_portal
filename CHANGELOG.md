# Changelog

## 1.3.0

The release that turned a demo into a product: a new name, real content in two
languages, a way to pay for it, and a website to find it from.

### Added

- **22 series, 164 episodes, in English and Urdu.** Five Prophets (Adam,
  Idris, Nuh, Hud, Salih) and six moral series (Fairness, Honesty, Kindness,
  Respect, Gratitude, Patience), each in both languages, with read-along
  captions. `tools/gen_series.dart` builds each one from the narration script
  and a whisper transcript; `tools/make_covers.ps1` produces the cover art.
  The six demo stories are gone.
- **Stories are series, not singles.** A series has a cover, a written
  introduction and episodes in order. Finishing one episode starts the next,
  carrying a running sleep timer, and stops at the end of the series.
- **An English / Urdu switch**, with Urdu laid out right to left.
- **Qissora Premium.** Free listeners get episode 1 of each series, stopping
  at the caption line nearest its halfway point; everything else shows a lock,
  enforced by the player including playback started from the lock screen.
  Monthly and yearly plans through Google Play Billing, priced by Play in the
  listener's own currency, with Google sign-in, purchase acknowledgement, and
  a check against Play on every launch whose answer is cached so a subscriber
  is not locked out offline.
- **A grown-up check** in front of anything that signs in or spends money — a
  multiplication a young child cannot pass. The Parents area skips it, being
  behind the PIN already.
- **An account card in the Parents area**: plan, Get Premium, Sign in with
  Google, Restore purchase, Manage subscription, Sign out, Delete account.
- **About and FAQ tabs**, each with a WhatsApp contact button.
- **The website, qissora.app**, built from the app's own design and content:
  every series browsable, the first episode of each playing free in a mini
  player that follows you down the page, read-along text, and the privacy
  policy at a public URL — which Play requires before a child-directed app can
  be listed. Deployed to Cloudflare from `site/`.

### Changed

- **The app is called Qissora.** Imaan Akhlaq already publishes an app under
  the old name. Display name, package and bundle id (`com.imaanakhlaq.qissora`),
  the Dart package, docs and licence all follow. Imaan & Akhlaq remains the
  publisher and the narrator.
- **Audio is streamed, not bundled.** ~170 MB of cut episodes live in
  Cloudflare R2 behind `audio.qissora.app` and are cached on the phone at first
  play, so a story still works offline afterwards. `tools/upload_audio.ps1`
  uploads them; `assets/audio/` is git-ignored. Covers stay bundled — they show
  on every screen and downloading them would leave grey boxes on a cold start.
- **Spoken trailers are retired** in favour of a written introduction per
  series.
- **The privacy policy and Play data-safety answers were rewritten.** Both
  still described 1.2.0, which had no networking at all: the policy claimed the
  app "does not connect to the internet", and the Play answers claimed no code
  could transmit anything. Submitting either would have meant filing a false
  declaration. The Play form now answers Yes for one data type — the parent's
  email address, collected by Google Sign-In even though no server of ours
  receives it.

### Fixed

- **Backups skipped entirely.** The audio cache pushed the app's backup past
  Android's 25 MB limit, which silently dropped the whole backup; the cache is
  excluded now.
- **The playback notification icon vanished from release builds.**
- **CI failed on a fresh clone.** A test asserted every episode's audio file
  existed on disk, which stopped being true once the audio left the repo.

### Release

- Release signing reads `android/key.properties` (git-ignored).
- Version 1.3.0 (build 5). 131 tests passing.

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
