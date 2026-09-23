import type { Metadata } from 'next';

import { PageHeader } from '@/components/PageHeader';
import { contact } from '@/lib/site';

export const metadata: Metadata = {
  title: 'Contact',
  description:
    'Get in touch with the Qissora team on WhatsApp or by email, and ask ' +
    'about the Imaan & Akhlaq programme for schools.',
  alternates: { canonical: '/contact' },
};

const ways = [
  {
    title: 'WhatsApp',
    body: 'The quickest reply. Questions, feedback or the school programme.',
    action: contact.whatsappDisplay,
    href: contact.whatsappUrl,
    tint: 'bg-peach-tint',
  },
  {
    title: 'Email',
    body: 'For longer messages and anything with documents attached.',
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
        title="Talk to us"
        lead="Any question about Qissora or the Imaan & Akhlaq programme — we would love to hear from you."
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
          <h2 className="text-xl">Schools and madaris</h2>
          <p className="mt-2 max-w-2xl text-sm leading-relaxed text-ink-soft">
            Imaan &amp; Akhlaq is a complete character-building programme:
            books, activities, clubs and the Qissora audio stories. Message us
            on WhatsApp to find out what it would look like at your school.
          </p>
        </div>
      </section>
    </>
  );
}
