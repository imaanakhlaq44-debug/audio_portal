import type { Metadata } from 'next';

import { PageHeader } from '@/components/PageHeader';
import { Prose } from '@/components/Prose';
import { contact } from '@/lib/site';

export const metadata: Metadata = {
  title: 'Privacy Policy',
  description:
    'The Qissora website privacy policy: no accounts, no ads and no ' +
    'tracking.',
  alternates: { canonical: '/privacy' },
};

export default function PrivacyPage() {
  return (
    <>
      <PageHeader
        eyebrow="Privacy"
        title="Privacy Policy"
        lead="This policy covers the qissora.app website. The app has its own policy, inside the app and on Google Play."
      />
      <Prose>
        <p>
          <strong>Effective date:</strong> 20 September 2026
          <br />
          <strong>Publisher:</strong> Imaan and Akhlaq Talks (Private) Limited,
          Islamabad, Pakistan
        </p>

        <h2>The short version</h2>
        <p>
          This website has no accounts, no advertising and no advertising or
          analytics trackers. We do not ask you for any personal information.
        </p>

        <h2>What we collect</h2>
        <ul>
          <li>
            <strong>No cookies.</strong> The website stores nothing in your
            browser.
          </li>
          <li>
            <strong>No analytics.</strong> We do not track your visits.
          </li>
          <li>
            <strong>No forms.</strong> Contact happens over WhatsApp or email,
            which you start yourself.
          </li>
        </ul>

        <h2>Hosting and audio</h2>
        <p>
          The website is hosted on Cloudflare Pages, and the story audio is
          served from Cloudflare. As with any website, the hosting provider
          may keep technical logs, such as an IP address and the time of a
          request, to keep the service running and secure. We do not use those
          logs for marketing.
        </p>

        <h2>Children</h2>
        <p>
          Qissora is made for children. This website neither asks for nor
          collects any personal information from them.
        </p>

        <h2>The app</h2>
        <p>
          In the Qissora app, listening progress, favourites and the parents
          PIN are kept on the phone itself. Premium subscriptions run through
          Google Play, and a parent&rsquo;s Google sign-in is used only to tie
          the subscription to their account. The app&rsquo;s own policy has
          the detail.
        </p>

        <h2>Contact</h2>
        <p>
          Any question, write to{' '}
          <a href={`mailto:${contact.email}`}>{contact.email}</a> or message{' '}
          <a href={contact.whatsappUrl}>WhatsApp {contact.whatsappDisplay}</a>.
        </p>
      </Prose>
    </>
  );
}
