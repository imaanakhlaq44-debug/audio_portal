import type { Metadata } from 'next';

import { PageHeader } from '@/components/PageHeader';
import { Prose } from '@/components/Prose';
import { contact } from '@/lib/site';

export const metadata: Metadata = {
  title: 'Terms of Use',
  description:
    'The terms that apply when you use the Qissora website and app, and ' +
    'the rights in our stories and artwork.',
  alternates: { canonical: '/terms' },
};

export default function TermsPage() {
  return (
    <>
      <PageHeader
        eyebrow="Legal"
        title="Terms of Use"
        lead="These terms apply when you use the Qissora website and app."
      />
      <Prose>
        <p>
          <strong>Effective date:</strong> 20 September 2026
        </p>

        <h2>Who we are</h2>
        <p>
          Qissora is a product of Imaan and Akhlaq Talks (Private) Limited,
          Islamabad, Pakistan. &ldquo;We&rdquo; means that company.
        </p>

        <h2>Using Qissora</h2>
        <ul>
          <li>
            The stories are for personal and family listening, and for schools
            with our permission.
          </li>
          <li>
            You may listen to the free preview on this website; the complete
            stories are in the app with Premium.
          </li>
          <li>
            Downloading the audio or artwork to republish it, sell it or post
            it on another platform is not allowed.
          </li>
        </ul>

        <h2>Content and copyright</h2>
        <p>
          All stories, narration, illustrations, the characters Imaan and
          Akhlaq, the logo and the name belong to us and are protected by
          copyright.
        </p>

        <h2>Subscriptions</h2>
        <p>
          Qissora Premium is sold through Google Play. Payment, renewal,
          cancellation and refunds follow Google Play&rsquo;s terms. You can
          cancel a subscription at any time in Google Play.
        </p>

        <h2>No warranty</h2>
        <p>
          We work hard to keep the website and app running well, but the
          service is provided &ldquo;as is&rdquo; and may change or stop at any
          time.
        </p>

        <h2>Changes</h2>
        <p>
          If these terms change, the new date will appear at the top of this
          page.
        </p>

        <h2>Contact</h2>
        <p>
          Questions: <a href={`mailto:${contact.email}`}>{contact.email}</a> or{' '}
          <a href={contact.whatsappUrl}>WhatsApp</a>.
        </p>
      </Prose>
    </>
  );
}
