# Privacy Policy — Qissora

**App:** Qissora — Kids Islamic Audio Stories by Imaan & Akhlaq
**Publisher:** Imaan and Akhlaq Talks (Private) Limited, Islamabad, Pakistan
**Contact:** imaanakhlaq44@gmail.com
**Published at:** https://qissora.app/app-privacy
**Effective date:** 20 September 2026

## The short version

Qissora has no ads, no analytics, no crash reporting and no third-party
tracking, and we run no server that stores anything about you.

The app does use the internet for three things: it streams the stories from
our own audio host, it lets a parent sign in with Google, and it sells the
Premium subscription through Google Play. Those are described below.

Everything the app remembers about your family — the child's name, favourites,
listening progress, the parents PIN — stays on the device.

## What the app sends over the internet

| What | Where it goes | Why |
|---|---|---|
| A request for a story's audio file | `audio.qissora.app`, our own host on Cloudflare R2 | The stories are not bundled in the app; they are fetched when played |
| A Google sign-in, if a parent chooses to sign in | Google | To find a Premium subscription that belongs to that Google account |
| A subscription purchase or restore | Google Play | To sell and check Qissora Premium |

**About the audio requests.** Like any request to any website, a request for a
story carries the device's IP address and reaches our host's standard server
logs. We do not attach a name, an account or an identifier of our own to those
requests, we do not build a profile from them, and the app sends nothing about
the child with them. A story is cached on the device the first time it plays,
so it is not re-fetched on later listens and it plays offline afterwards.

**About signing in.** Signing in with Google is optional and is only needed to
buy or restore Premium. It asks Google for the account's email address, which
the app shows in the Parents area and keeps on the device so a subscriber is
recognised on the next launch. **We do not send that email anywhere** — there
is no Qissora account and no Qissora server to send it to. Signing out in the
Parents area removes it from the device. What Google does with a sign-in is
covered by [Google's Privacy Policy](https://policies.google.com/privacy).

**About payments.** Google Play handles the entire purchase. The app never
sees or stores a card number, billing address or any other payment detail; it
only learns from Google Play whether a subscription is currently active. Play's
own handling of a purchase is covered by Google's privacy policy.

## What the app stores on the device

All of this is written to the app's own private storage. None of it is sent to
us, and we never see it:

| What | Why |
|---|---|
| The child's first name, as typed by a parent | To greet the child on the home screen |
| Which stories are marked favourite or saved | To show them in the Library |
| Playback position and play counts per story | "Continue listening", and the listening stats in the parents area |
| Downloaded story audio, cached after the first play | So a story plays again without using data, and works offline |
| The parents PIN, stored only as a salted PBKDF2 hash — never the PIN itself | To lock the parents area |
| Count of incorrect PIN entries and any lockout deadline | To rate-limit wrong entries |
| The signed-in parent's email address, if a parent signed in | To show which account holds Premium |
| Whether Premium is active, as last reported by Google Play | So a subscriber keeps Premium while offline |
| Theme choice, story language, and last sleep-timer length | To keep your preferences between sessions |

**Deleting it.** Clearing the app's data or uninstalling the app removes all of
it permanently. Inside the app, the parents area can clear favourites, saved
stories and listening history individually, and signing out removes the stored
email address. There is no copy on any server of ours, so there is nothing for
us to delete on request — and no way for us to restore it.

To cancel Premium or delete what Google holds about your purchase, use your
Google account and Google Play; that data is theirs, not ours.

**Device backups.** If the device owner has enabled the operating system's own
backup (for example Android Backup or iCloud), the app's data may be included
in that backup under the account of the device owner. That backup is handled by
Google or Apple under their own privacy policies, not by us.

## What the app does not do

- No Qissora account, and no server of ours that stores your data.
- No advertising, and no advertising identifiers.
- No analytics, crash reporting or usage telemetry.
- No location, contacts, camera, microphone or photo access.
- No social media features, no sharing, no user-generated content.
- Nothing sold or shared with anyone.

## Permissions the app requests

| Permission | Why |
|---|---|
| `INTERNET`, `ACCESS_NETWORK_STATE` | To stream the stories, and to notice when the device is offline |
| `FOREGROUND_SERVICE`, `FOREGROUND_SERVICE_MEDIA_PLAYBACK`, `WAKE_LOCK` | To keep a story playing when the screen is locked or the app is in the background |
| `POST_NOTIFICATIONS` | To show the playback notification with pause / skip controls |
| `com.android.vending.BILLING` | To sell Qissora Premium through Google Play |
| `USE_BIOMETRIC`, `USE_FINGERPRINT` | Added by Google's own sign-in libraries, which can offer a fingerprint instead of a password on the Google sign-in screen. Qissora itself never asks for a fingerprint and never receives one |

## Children's privacy

This app is made for children and is meant to be used with a parent or
guardian, and we have designed it so that **nothing about the child is ever
transmitted**. The child's first name, their favourites and their listening
history are entered and kept on the device and never leave it. The app shows no
ads, contains no analytics or tracking SDKs, and has no social or sharing
features.

The parts that do use the internet are the parents' parts: streaming the
stories, and — only if a parent chooses — signing in with Google to buy or
restore the Premium subscription. Those are intended for the adult, and a
parent who never signs in never sends us or Google anything but a request for a
story file.

We believe this meets the US Children's Online Privacy Protection Act (COPPA)
and the EU GDPR's provisions on children's data. We do not knowingly collect
personal information from children.

## Changes to this policy

If the app begins collecting or transmitting anything beyond what is described
above, this policy will be updated and the effective date changed before that
version is released.

## Contact

Questions about this policy: imaanakhlaq44@gmail.com
