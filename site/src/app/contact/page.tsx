import type { Metadata } from 'next';

import { PageHeader } from '@/components/PageHeader';
import { contact } from '@/lib/site';

export const metadata: Metadata = {
  title: 'Contact',
  description:
    'Qissora team se rabta karein: WhatsApp ya email. Schools aur madaris ' +
    'ke liye Imaan & Akhlaq program ki maloomat bhi.',
  alternates: { canonical: '/contact' },
};

const ways = [
  {
    title: 'WhatsApp',
    body: 'Sab se tez jawab. Sawal, mashwara ya school program ke liye.',
    action: contact.whatsappDisplay,
    href: contact.whatsappUrl,
    tint: 'bg-peach-tint',
  },
  {
    title: 'Email',
    body: 'Tafseeli baat ya documents bhejne ke liye.',
    action: contact.email,
    href: `mailto:${contact.email}`,
    tint: 'bg-sky-tint',
  },
];

export default function ContactPage() {
  return (
    <>
      <PageHeader
        eyebrow="Contact"
        title="Hum se baat karein"
        lead="Qissora ya Imaan & Akhlaq program ke baare mein koi bhi sawal ho, hum sunne ke liye hazir hain."
      />

      <section className="section pb-16">
        <ul className="grid gap-5 sm:grid-cols-2">
          {ways.map((w) => (
            <li
              key={w.title}
              className={`rounded-[var(--radius-card)] ${w.tint} p-6`}
            >
              <h2 className="text-2xl">{w.title}</h2>
              <p className="mt-2 text-sm text-ink-soft">{w.body}</p>
              <a href={w.href} className="btn-primary mt-5 text-sm">
                {w.action}
              </a>
            </li>
          ))}
        </ul>

        <div className="card mt-6 p-6">
          <h2 className="text-xl">Schools aur madaris</h2>
          <p className="mt-2 max-w-2xl text-sm leading-relaxed text-ink-soft">
            Imaan &amp; Akhlaq aik mukammal character-building program hai:
            kitabein, activities, clubs aur Qissora ki audio kahaniyan. Apne
            school ke liye maloomat chahiye to WhatsApp par rabta karein.
          </p>
        </div>
      </section>
    </>
  );
}
