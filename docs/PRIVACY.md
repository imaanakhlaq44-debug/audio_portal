# Privacy Policy — Imaan & Akhlaq

> **DRAFT — needs your details before it is published.**
> Replace every `[[...]]` placeholder, publish it at a public URL, and paste
> that URL into the Play Console (and App Store Connect) listing. Google
> requires the policy to be reachable without logging in, on a page you
> control. See [`play-data-safety.md`](play-data-safety.md) for the matching
> store-form answers.

**App:** Imaan & Akhlaq — Kids Islamic Audio Story Portal
**Developer:** `[[your name or company]]`
**Contact:** `[[support email]]`
**Effective date:** `[[date you publish this]]`

## The short version

Imaan & Akhlaq does not collect, transmit or share any personal information.
The app has no accounts, no ads, no analytics and no third-party tracking. It
does not connect to the internet at all — every story, image and font is
bundled inside the app.

Anything the app remembers stays on the device it was entered on.

## What the app stores on the device

All of this is written to the app's own private storage. None of it leaves
the device, and we — the developer — never see it:

| What | Why |
|---|---|
| The child's first name, as typed by a parent | To greet the child on the home screen |
| Which stories are marked favourite or saved | To show them in the Library |
| Playback position and play counts per story | "Continue listening", and the listening stats in the parents area |
| The parents PIN, stored only as a salted PBKDF2 hash — never the PIN itself | To lock the parents area |
| Count of incorrect PIN entries and any lockout deadline | To rate-limit wrong entries |
| Theme choice (light / dark / system) and last sleep-timer length | To keep your preferences between sessions |

**Deleting it.** Clearing the app's data or uninstalling the app removes all
of it permanently. Inside the app, the parents area can clear favourites,
saved stories and listening history individually. There is no copy anywhere
else, so there is nothing for us to delete on request — and no way for us to
restore it.

**Device backups.** If the device owner has enabled the operating system's
own backup (for example Android Backup or iCloud), the app's data may be
included in that backup under the account of the device owner. That backup is
handled by Google or Apple under their own privacy policies, not by us.

## What the app does not do

- No account, login, email address or phone number.
- No advertising, and no advertising identifiers.
- No analytics, crash reporting or usage telemetry.
- No location, contacts, camera, microphone or photo access.
- No social media features, sharing or in-app purchases.
- No data sold or shared with anyone, because none is collected.

## Permissions the app requests

| Permission | Why |
|---|---|
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `WAKE_LOCK` | To keep a story playing when the screen is locked or the app is in the background |
| `POST_NOTIFICATIONS` | To show the playback notification with pause / skip controls |

The app does **not** request internet access. `[[If you ever add a feature
that needs it, this policy and the store's data-safety answers must be
updated first.]]`

## Children's privacy

This app is designed for children and is intended to be used with a parent or
guardian. It complies with the US Children's Online Privacy Protection Act
(COPPA) and the EU GDPR's provisions on children's data by the simplest route
available: it collects nothing, transmits nothing, and contains no ads or
third-party SDKs that could.

The child's first name is entered by a parent, is used only to display a
greeting on the device, and never leaves that device.

## Changes to this policy

If the app ever begins collecting or transmitting data, this policy will be
updated and the effective date above changed before that version is released.

## Contact

Questions about this policy: `[[support email]]`
