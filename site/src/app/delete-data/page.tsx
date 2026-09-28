import type { Metadata } from 'next';
import Link from 'next/link';

import { PageHeader } from '@/components/PageHeader';
import { Prose } from '@/components/Prose';
import { contact } from '@/lib/site';

export const metadata: Metadata = {
  title: 'Delete your data',
  description:
    'How to delete what the Qissora app keeps about your family: on the ' +
    'phone, and the VIP or school code record on our server.',
  alternates: { canonical: '/delete-data' },
};

export default function DeleteDataPage() {
  return (
    <>
      <PageHeader
        eyebrow="Privacy"
        title="Delete your data"
        lead="How to delete what the Qissora app, by Imaan and Akhlaq Talks, keeps about your family."
      />
      <Prose>
        <p>
          Almost everything Qissora remembers lives only on your phone. The one
          thing our server keeps is a record of a VIP or school code, and only
          if a parent redeemed one. This page covers both.
        </p>

        <h2>Delete the code record on our server</h2>
        <p>
          <strong>What it is:</strong> a one-way hash of the ID of the Google
          account that redeemed the code, which code it was, when it was
          redeemed, and when it ends. We do not keep the email address, name or
          anything about the child.
        </p>

        <h3>In the app (quickest)</h3>
        <ol>
          <li>Open Qissora and go to the Parents area (enter the parents PIN).</li>
          <li>
            If you are not signed in, choose <strong>Sign in with Google</strong>{' '}
            and pick the account that redeemed the code.
          </li>
          <li>
            Choose <strong>Delete account</strong>, then <strong>Delete</strong>,
            and confirm the account when Google asks.
          </li>
        </ol>
        <p>
          The record is deleted from our server straight away, for every code
          that account redeemed. If the phone is offline the app says so: sign
          in again and retry when you are online.
        </p>

        <h3>By email</h3>
        <p>
          Write to <a href={`mailto:${contact.email}`}>{contact.email}</a> with
          the subject &ldquo;Qissora: delete my data&rdquo; and the{' '}
          <strong>VIP code</strong> you redeemed (it looks like QV-XXXX-XXXX).
          We delete its record within 30 days and reply to confirm. We cannot
          find a family&rsquo;s record from an email address, because we never
          store one; a school code is shared by many families, so a school-code
          record can only be deleted from the app.
        </p>

        <h3>What happens after</h3>
        <ul>
          <li>
            The code stops working on every phone. Premium from a Google Play
            subscription is not affected.
          </li>
          <li>
            Nothing is kept afterwards: no backup copy, and no retention period.
          </li>
          <li>
            A family that deletes a school-code record may redeem a school code
            again.
          </li>
        </ul>

        <h2>Delete what is on your phone</h2>
        <p>
          The child&rsquo;s name, favourites, saved stories, listening history,
          the parents PIN and the signed-in email are stored only on the phone.
          We never receive them, so there is nothing for us to delete.
        </p>
        <ul>
          <li>
            <strong>Some of it:</strong> the Parents area can clear favourites,
            saved stories and listening history, and{' '}
            <strong>Sign out</strong> removes the stored email.
          </li>
          <li>
            <strong>All of it:</strong> uninstall the app, or open your
            phone&rsquo;s Settings, then Apps, Qissora, Storage, and choose{' '}
            <strong>Clear data</strong>.
          </li>
        </ul>

        <h2>What Google holds</h2>
        <p>
          A Premium subscription and its purchase history belong to your Google
          account and Google Play. Cancel the subscription in Google Play, and
          manage what Google keeps from your Google account.
        </p>

        <p>
          Questions: <a href={`mailto:${contact.email}`}>{contact.email}</a> or{' '}
          <a href={contact.whatsappUrl}>WhatsApp {contact.whatsappDisplay}</a>.
          The full <Link href="/app-privacy">app privacy policy</Link> has the
          detail.
        </p>
      </Prose>
    </>
  );
}
