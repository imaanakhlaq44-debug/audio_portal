import type { Metadata } from 'next';
import Link from 'next/link';

import { PageHeader } from '@/components/PageHeader';
import { Prose } from '@/components/Prose';
import { contact } from '@/lib/site';

export const metadata: Metadata = {
  title: 'App Privacy Policy',
  description:
    'The Qissora app privacy policy: nothing about your child leaves the ' +
    'phone, and no server of ours stores anything about your family.',
  alternates: { canonical: '/app-privacy' },
};

export default function AppPrivacyPage() {
  return (
    <>
      <PageHeader
        eyebrow="Privacy"
        title="App Privacy Policy"
        lead="This policy covers the Qissora app on your phone. The website has its own, shorter policy."
      />
      <Prose>
        <p>
          <strong>App:</strong> Qissora — Kids Islamic Audio Stories
          <br />
          <strong>Publisher:</strong> Imaan and Akhlaq Talks (Private) Limited,
          Islamabad, Pakistan
          <br />
          <strong>Effective date:</strong> 20 September 2026
        </p>

        <h2>The short version</h2>
        <p>
          Qissora has no ads, no analytics, no crash reporting and no
          third-party tracking, and we run no server that stores anything about
          you.
        </p>
        <p>
          The app uses the internet for three things: it streams the stories
          from our own audio host, it lets a parent sign in with Google, and it
          sells the Premium subscription through Google Play. Each is described
          below.
        </p>
        <p>
          Everything the app remembers about your family — the child&rsquo;s
          name, favourites, listening progress, the parents PIN — stays on the
          phone.
        </p>

        <h2>What the app sends over the internet</h2>
        <ul>
          <li>
            <strong>A request for a story&rsquo;s audio,</strong> to{' '}
            <code>audio.qissora.app</code>, our own host. The stories are not
            bundled inside the app; they are fetched when played.
          </li>
          <li>
            <strong>A Google sign-in,</strong> to Google, if a parent chooses to
            sign in. It is used to find a Premium subscription belonging to that
            Google account.
          </li>
          <li>
            <strong>A subscription purchase or restore,</strong> to Google Play,
            to sell and check Qissora Premium.
          </li>
        </ul>

        <h3>About the audio requests</h3>
        <p>
          Like any request to any website, a request for a story carries the
          device&rsquo;s IP address and reaches our host&rsquo;s standard server
          logs. We do not attach a name, an account or an identifier of our own
          to those requests, we do not build a profile from them, and the app
          sends nothing about the child with them. A story is kept on the phone
          the first time it plays, so it is not fetched again on later listens
          and it plays offline afterwards.
        </p>

        <h3>About signing in</h3>
        <p>
          Signing in with Google is optional, and is only needed to buy or
          restore Premium. It asks Google for the account&rsquo;s email address,
          which the app shows in the Parents area and keeps on the phone so a
          subscriber is recognised on the next launch.{' '}
          <strong>We do not send that email anywhere</strong> — there is no
          Qissora account and no Qissora server to send it to. Signing out in
          the Parents area removes it from the phone. What Google does with a
          sign-in is covered by{' '}
          <a href="https://policies.google.com/privacy">
            Google&rsquo;s Privacy Policy
          </a>
          .
        </p>

        <h3>About payments</h3>
        <p>
          Google Play handles the entire purchase. The app never sees or stores
          a card number, billing address or any other payment detail; it only
          learns from Google Play whether a subscription is currently active.
        </p>

        <h2>What the app stores on the phone</h2>
        <p>
          All of this is written to the app&rsquo;s own private storage. None of
          it is sent to us, and we never see it:
        </p>
        <ul>
          <li>
            The child&rsquo;s first name, as typed by a parent, to greet them on
            the home screen.
          </li>
          <li>Which stories are marked favourite or saved.</li>
          <li>
            Playback position and play counts per story, for &ldquo;Continue
            listening&rdquo; and the listening stats in the Parents area.
          </li>
          <li>Story audio, kept after the first play so it works offline.</li>
          <li>
            The parents PIN, stored only as a salted PBKDF2 hash — never the PIN
            itself.
          </li>
          <li>
            The count of incorrect PIN entries and any lockout deadline, to
            rate-limit wrong entries.
          </li>
          <li>
            The signed-in parent&rsquo;s email address, if a parent signed in.
          </li>
          <li>
            Whether Premium is active, as last reported by Google Play, so a
            subscriber keeps Premium while offline.
          </li>
          <li>
            Theme choice, story language and the last sleep-timer length.
          </li>
        </ul>

        <h3>Deleting it</h3>
        <p>
          Clearing the app&rsquo;s data or uninstalling the app removes all of
          it permanently. Inside the app, the Parents area can clear favourites,
          saved stories and listening history individually, and signing out
          removes the stored email address. There is no copy on any server of
          ours, so there is nothing for us to delete on request — and no way for
          us to restore it.
        </p>
        <p>
          To cancel Premium or delete what Google holds about your purchase, use
          your Google account and Google Play; that data is theirs, not ours.
        </p>

        <h3>Device backups</h3>
        <p>
          If the device owner has turned on the operating system&rsquo;s own
          backup — Android Backup or iCloud — the app&rsquo;s data may be
          included in that backup under the device owner&rsquo;s account. That
          backup is handled by Google or Apple under their own privacy policies,
          not by us.
        </p>

        <h2>What the app does not do</h2>
        <ul>
          <li>No Qissora account, and no server of ours that stores your data.</li>
          <li>No advertising, and no advertising identifiers.</li>
          <li>No analytics, crash reporting or usage telemetry.</li>
          <li>No location, contacts, camera, microphone or photo access.</li>
          <li>No social features, no sharing, no user-generated content.</li>
          <li>Nothing sold or shared with anyone.</li>
        </ul>

        <h2>Permissions the app asks for</h2>
        <ul>
          <li>
            <strong>Internet and network state</strong> — to stream the stories,
            and to notice when the phone is offline.
          </li>
          <li>
            <strong>Foreground service, media playback and wake lock</strong> —
            to keep a story playing when the screen is locked or the app is in
            the background.
          </li>
          <li>
            <strong>Notifications</strong> — to show the playback notification
            with pause and skip controls.
          </li>
          <li>
            <strong>Billing</strong> — to sell Qissora Premium through Google
            Play.
          </li>
          <li>
            <strong>Biometric and fingerprint</strong> — added by Google&rsquo;s
            own sign-in libraries, which can offer a fingerprint instead of a
            password on the Google sign-in screen. Qissora itself never asks for
            a fingerprint and never receives one.
          </li>
        </ul>

        <h2>Children</h2>
        <p>
          This app is made for children and is meant to be used with a parent or
          guardian, and we have designed it so that{' '}
          <strong>nothing about the child is ever transmitted</strong>. The
          child&rsquo;s first name, their favourites and their listening history
          are entered and kept on the phone and never leave it. The app shows no
          ads, contains no analytics or tracking, and has no social or sharing
          features.
        </p>
        <p>
          The parts that do use the internet are the parents&rsquo; parts:
          streaming the stories, and — only if a parent chooses — signing in
          with Google to buy or restore Premium. A parent who never signs in
          never sends us or Google anything but a request for a story file.
        </p>
        <p>
          We believe this meets the US Children&rsquo;s Online Privacy
          Protection Act (COPPA) and the EU GDPR&rsquo;s provisions on
          children&rsquo;s data. We do not knowingly collect personal
          information from children.
        </p>

        <h2>Changes to this policy</h2>
        <p>
          If the app begins collecting or transmitting anything beyond what is
          described above, this policy will be updated and the effective date
          changed before that version is released.
        </p>

        <h2>Contact</h2>
        <p>
          Questions about this policy: write to{' '}
          <a href={`mailto:${contact.email}`}>{contact.email}</a> or message{' '}
          <a href={contact.whatsappUrl}>WhatsApp {contact.whatsappDisplay}</a>.
        </p>
        <p>
          The <Link href="/privacy">website privacy policy</Link> covers
          qissora.app itself.
        </p>
      </Prose>
    </>
  );
}
