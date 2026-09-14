# Play Console: Data safety & Families answers

Working answers for the Google Play **Data safety** form and the **Families**
policy sections, with the reason for each. Every claim here was checked
against the code at the commit that added this file — see "How this was
verified" at the end, and re-check it before each release.

The App Store's Privacy Nutrition Label asks the same questions in different
words; the answers are the same.

---

## Data safety form

### Does your app collect or share any of the required user data types?

**No.**

"Collect" in Google's definition means transmitting data off the device.
This app has no networking code at all and the release manifest declares no
`INTERNET` permission, so nothing can be transmitted.

Answering "no" here means the rest of the data-type checklist stays empty:
no location, personal info, financial info, health, messages, photos, audio,
files, calendar, contacts, app activity, web browsing, app info or device
identifiers.

> **The trap.** The app *does* store a child's first name, favourites and
> listening history **on the device**. That is not "collection" under the
> Play definition — on-device-only processing is explicitly excluded — so the
> honest answer is still "no". The privacy policy describes the local storage
> anyway, because parents deserve to know it exists.

### Is all of the user data encrypted in transit?

Not applicable — no data is transmitted. (If the form forces an answer,
"Yes", with the explanation that there is no transit.)

### Do you provide a way for users to request that their data is deleted?

**Yes — deleted on device.** Uninstalling or clearing app data removes
everything, and the parents area can clear favourites, saved stories and
listening history individually. There is no server-side copy to request
deletion of.

### Data types checklist

Leave every category unchecked. In particular:

| Category | Answer | Why |
|---|---|---|
| Personal info → Name | Not collected | The child's name is stored on-device only |
| App activity → App interactions | Not collected | Listening history never leaves the device |
| App info and performance → Crash logs | Not collected | No crash-reporting SDK is integrated |
| Device or other IDs | Not collected | No advertising or analytics identifiers |

---

## Families policy

| Question | Answer |
|---|---|
| Target audience | **Children.** Age groups: *Ages 5 and under* and *Ages 6–8* (adjust to your intended range) |
| Does the app appeal to children? | Yes — it is a children's audio-story app |
| Ads | **No ads of any kind** |
| Ad SDKs | None. The Families ads-SDK certification does not apply |
| In-app purchases | None |
| Analytics / third-party SDKs that collect data | None |
| Social features / user-generated content | None |
| Requires an account | No |
| Data collection from children | None |
| Privacy policy URL | Required — publish [`PRIVACY.md`](PRIVACY.md) at a public URL and link it here |

**Content rating questionnaire.** The app contains narrated Islamic and moral
stories for children: no violence, no profanity, no user interaction, no
sharing of location or personal information. Expect an *Everyone* / PEGI 3
rating.

---

## What would change these answers

Re-open this file if any of the following lands — each one turns at least one
"no" into a "yes", and shipping without updating the form is a policy
violation, not a paperwork slip:

- **Any analytics or crash reporting** (Firebase, Crashlytics, Sentry) →
  collects device identifiers and crash logs.
- **Any ads** → Families policy requires a certified ads SDK and changes the
  ad-ID answers.
- **Adding `INTERNET` permission** — for example a remote story catalogue,
  streaming audio, or reverting to runtime font fetching. Note that fonts are
  bundled specifically so the app does not need this.
- **Cloud backup or account sync** of progress and favourites.
- **Any third-party SDK at all**, even one that "only" reads a device ID.

---

## How this was verified

Against the code, not against memory:

- **No networking:** a search across `lib/` for `http`, `HttpClient`,
  `Socket`, `fetch(` and `Uri.parse('http...')` returns nothing. The only
  `Uri.parse` in the app builds an `asset:///` URI for notification cover art.
- **No `INTERNET` permission** in `android/app/src/main/AndroidManifest.xml`.
  It appears only in `src/debug/`, which Flutter adds for hot reload and which
  is not part of a release build.
- **Declared permissions** are exactly `WAKE_LOCK`, `FOREGROUND_SERVICE`,
  `FOREGROUND_SERVICE_MEDIA_PLAYBACK` and `POST_NOTIFICATIONS`.
- **No tracking keys** in `ios/Runner/Info.plist` (`NSUserTrackingUsageDescription`,
  `SKAdNetworkItems` are both absent).
- **Dependencies** are `provider`, `crypto`, `hive`/`hive_flutter`,
  `just_audio`, `audio_service`, `audio_session`, `path_provider`, `intl`,
  `google_fonts`, `cupertino_icons` — none of which collect or transmit user
  data. `google_fonts` can fetch over the network, which is why
  `GoogleFonts.config.allowRuntimeFetching = false` is set in `main()` and the
  font files are bundled.
- **On-device data** is the key list in `lib/services/storage_service.dart`
  plus the per-story progress box; the privacy policy table mirrors it.

`shared_preferences` and `intl` are declared in `pubspec.yaml` but not
imported anywhere. They collect nothing, so they change no answer here, but
removing unused dependencies is worth doing before a store review.
