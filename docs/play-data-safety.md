# Play Console: Data safety & Families answers

Working answers for the Google Play **Data safety** form and the **Families**
policy sections, with the reason for each. Every claim was checked against the
code at the commit that last touched this file — see "How this was verified" at
the end, and re-check it before each release.

The App Store's Privacy Nutrition Label asks the same questions in different
words; the answers are the same, except that Premium does not exist on iOS.

> **These answers changed in 1.3.0.** Up to 1.2.0 the app had no networking at
> all and every answer here was "no". It now streams its audio, signs a parent
> in with Google, and sells a subscription. Anyone re-submitting the old form
> would be filing a false declaration.

---

## Data safety form

### Does your app collect or share any of the required user data types?

**Yes** — one type, from the parent, and only if they choose to sign in.

Play defines "collect" as transmitting data off the device, and counts data
that a third-party SDK in your app transmits as collected by your app. Google
Sign-In transmits the parent's Google account details, so it must be declared
even though no server of ours receives them.

### Data types checklist

| Category | Answer | Why |
|---|---|---|
| **Personal info → Email address** | **Collected**, not shared | `google_sign_in` returns the account's email when a parent signs in to buy or restore Premium. It is shown in the Parents area and stored on the device; we operate no server that receives it |
| Personal info → Name | Not collected | The child's name is typed by a parent and stored on-device only |
| Financial info → Purchase history | Not collected *by us* | Google Play runs the whole purchase. The app only asks Play whether a subscription is active, and stores that yes/no on the device |
| App activity → App interactions | Not collected | Favourites and listening history never leave the device |
| Music and audio files | Not collected | Audio flows the other way — the app downloads stories and uploads nothing |
| App info and performance → Crash logs | Not collected | No crash-reporting SDK is integrated |
| Device or other IDs | Not collected | No advertising or analytics identifiers. Story requests reach our host's ordinary server logs with the device's IP, which Play's guidance does not treat as a declarable data type on its own |
| Location, health, messages, photos, files, calendar, contacts, web browsing | Not collected | The app has no code that touches any of them |

For the email address, answer the follow-up questions:

| Follow-up | Answer |
|---|---|
| Collected or shared? | Collected, not shared |
| Processed ephemerally? | No — it is stored on the device until the parent signs out |
| Required or optional? | **Optional.** Everything except buying Premium works without signing in |
| Purpose | **Account management** (identifying the subscription's owner) |

### Is all of the user data encrypted in transit?

**Yes.** Sign-in and billing go over Google's own HTTPS APIs, and story audio is
fetched over HTTPS from `audio.qissora.app`. The release network-security config
permits cleartext only for `127.0.0.1`, which is the local proxy `just_audio`
uses to cache a stream on the device — that traffic never leaves the phone.

### Do you provide a way for users to request that their data is deleted?

**Yes — deleted on device.** Signing out in the Parents area removes the stored
email address. Uninstalling or clearing app data removes everything, and the
parents area can clear favourites, saved stories and listening history
individually. We hold no server-side copy to delete. Subscription data belongs
to Google Play and is deleted through the user's Google account.

---

## Families policy

| Question | Answer |
|---|---|
| Target audience | **Children.** Age groups: *Ages 5 and under* and *Ages 6–8* (adjust to your intended range) |
| Does the app appeal to children? | Yes — it is a children's audio-story app |
| Ads | **No ads of any kind** |
| Ad SDKs | None. The Families ads-SDK certification does not apply |
| **In-app purchases** | **Yes — "Qissora Premium", a subscription (monthly and annual base plans) sold through Google Play Billing** |
| Analytics / third-party SDKs that collect data | None |
| Social features / user-generated content | None |
| Requires an account | No. A Google sign-in is needed only to buy or restore Premium |
| Data collection from children | None. Nothing about the child is transmitted |
| Privacy policy URL | **https://qissora.app/app-privacy** — the same text as [`PRIVACY.md`](PRIVACY.md), served from `site/src/app/app-privacy/page.tsx`. Change both together |

**Content rating questionnaire.** The app contains narrated Islamic and moral
stories for children: no violence, no profanity, no user interaction, no sharing
of location or personal information. It does contain a digital purchase, which
the questionnaire asks about separately. Expect an *Everyone* / PEGI 3 rating.

### The parental gate

Play's Families requirements expect purchase flows in a child-directed app to
sit behind a parental gate — a check a young child cannot pass. The app has one:
`confirmGrownUp` in `lib/widgets/paywall_sheet.dart` asks the product of two
numbers between 6 and 9, and returns false on a wrong answer or a dismissal.

Every path that signs in or spends money passes through it:

| Path | Gate |
|---|---|
| Paywall → subscribe (`paywall_sheet.dart`, `_CheckoutState._buy`) | `confirmGrownUp` before `premium.subscribe` |
| Paywall → restore (`paywall_sheet.dart`) | `runPremiumAction`, which gates by default |
| Parents area → restore and sign-in (`parents_dashboard_screen.dart`) | `gate: false`, because the whole screen is already behind the parents PIN |

`PremiumService.subscribe` calls Google sign-in itself, and it is only reachable
from the gated `_buy`, so there is no route to a Google account picker or a Play
purchase sheet that skips the check. `test/premium_test.dart` covers it: a wrong
answer is rejected and the purchase does not proceed.

The paywall *sheet* opens without a gate, from the home, series and Now Playing
screens. That is deliberate — it only describes what Premium is. Nothing on it
reaches an account or a charge until the question is answered.

---

## What would change these answers

Re-open this file if any of the following lands — each one turns at least one
answer here, and shipping without updating the form is a policy violation, not a
paperwork slip:

- **Any analytics or crash reporting** (Firebase, Crashlytics, Sentry) →
  collects device identifiers and crash logs.
- **Any ads** → Families policy requires a certified ads SDK and changes the
  ad-ID answers.
- **A server of ours that receives anything** — a Qissora account, progress
  sync, receipt validation, or a newsletter sign-up. Today the honest claim is
  that we run no such server, and it is load-bearing in several answers above.
- **Per-user identifiers on the audio requests** — a signed URL carrying an
  account id, or any per-install token. That would turn story requests into
  collection tied to a person.
- **Premium on iOS**, which adds StoreKit and an Apple purchase flow.

---

## How this was verified

Against the code, not against memory:

- **Networking** is: story audio over HTTPS from `audioBaseUrl` in
  `lib/audio_config.dart`; `google_sign_in`; and `in_app_purchase` /
  `in_app_purchase_android`. There is no HTTP client of our own and no endpoint
  of ours other than the static audio host.
- **Permissions in the merged release manifest** are `INTERNET`,
  `ACCESS_NETWORK_STATE`, `WAKE_LOCK`, `FOREGROUND_SERVICE`,
  `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `POST_NOTIFICATIONS`,
  `com.android.vending.BILLING`, and `USE_BIOMETRIC` / `USE_FINGERPRINT`. The
  last two arrive from Google's sign-in and credential libraries; no code in
  `lib/` mentions biometrics, and the app never calls a biometric API.
- **Cleartext is off** except `127.0.0.1`, per
  `android/app/src/main/res/xml/network_security_config.xml`.
- **No tracking keys** in `ios/Runner/Info.plist`
  (`NSUserTrackingUsageDescription`, `SKAdNetworkItems` are both absent).
- **On-device data** is the key list in `lib/services/storage_service.dart` plus
  the per-story progress box and the audio cache written by
  `lib/services/story_audio_handler.dart`; the privacy policy table mirrors it.
- **The email address** is written by `StorageService.setAccountEmail` and
  cleared on sign-out; grep for `_keyAccountEmail` shows it is read only to
  display it in the Parents area.
- **`google_fonts`** can fetch over the network, so
  `GoogleFonts.config.allowRuntimeFetching = false` is still set in `main()` and
  the font files are still bundled. That is now a size and reliability choice
  rather than a networking one.

`shared_preferences` and `intl` are declared in `pubspec.yaml` but not imported
anywhere. They collect nothing, so they change no answer here, but removing
unused dependencies is worth doing before a store review.
