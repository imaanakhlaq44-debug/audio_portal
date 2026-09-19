import type { Metadata } from 'next';

import { PageHeader } from '@/components/PageHeader';
import { Prose } from '@/components/Prose';
import { contact } from '@/lib/site';

export const metadata: Metadata = {
  title: 'Terms of Use',
  description:
    'Qissora website aur app ke istemal ki shartein, aur content ke ' +
    'haqooq ke baare mein maloomat.',
  alternates: { canonical: '/terms' },
};

export default function TermsPage() {
  return (
    <>
      <PageHeader
        eyebrow="Legal"
        title="Terms of Use"
        lead="Qissora website aur app istemal karte waqt yeh shartein lagu hoti hain."
      />
      <Prose>
        <p>
          <strong>Effective date:</strong> 20 September 2026
        </p>

        <h2>Who we are</h2>
        <p>
          Qissora, Imaan and Akhlaq Talks (Private) Limited (Islamabad,
          Pakistan) ka product hai. &ldquo;Hum&rdquo; se murad yahi company
          hai.
        </p>

        <h2>Using Qissora</h2>
        <ul>
          <li>
            Kahaniyan zaati aur ghareloo istemal ke liye hain, aur schools
            mein hamari ijazat se.
          </li>
          <li>
            Website par diya gaya free preview aap sun sakte hain; poori
            kahaniyan app mein Premium ke saath milti hain.
          </li>
          <li>
            Audio ya illustrations ko download kar ke dobara publish karna,
            bechna, ya kisi aur platform par lagana mana hai.
          </li>
        </ul>

        <h2>Content and copyright</h2>
        <p>
          Saari kahaniyan, narration, illustrations, characters (Imaan aur
          Akhlaq), logo aur naam hamari milkiyat hain aur copyright ke tehat
          mehfooz hain.
        </p>

        <h2>Subscriptions</h2>
        <p>
          Qissora Premium Google Play ke zariye bikti hai. Payment, renewal,
          cancel karna aur refund Google Play ki shartoon ke mutabiq hote
          hain. Subscription aap kabhi bhi Google Play mein cancel kar sakte
          hain.
        </p>

        <h2>No warranty</h2>
        <p>
          Hum website aur app ko behtar rakhne ki poori koshish karte hain,
          lekin service &ldquo;as is&rdquo; di jati hai. Kisi waqt service
          bandh ya tabdeel ho sakti hai.
        </p>

        <h2>Changes</h2>
        <p>
          In shartoon mein tabdeeli ki soorat mein nayi tareekh yahan likhi
          jayegi.
        </p>

        <h2>Contact</h2>
        <p>
          Sawal ke liye <a href={`mailto:${contact.email}`}>{contact.email}</a>{' '}
          ya <a href={contact.whatsappUrl}>WhatsApp</a>.
        </p>
      </Prose>
    </>
  );
}
