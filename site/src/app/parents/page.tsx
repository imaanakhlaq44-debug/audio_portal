import type { Metadata } from 'next';

import { CtaSection } from '@/components/CtaSection';
import { PageHeader } from '@/components/PageHeader';
import { ParentSection } from '@/components/ParentSection';
import { Section } from '@/components/Section';

export const metadata: Metadata = {
  title: 'For Parents',
  description:
    'Qissora walidain ke liye: safe content, no ads, no tracking, parents ' +
    'area PIN ke peeche, sleep timer aur listening stats.',
  alternates: { canonical: '/parents' },
};

const faqs = [
  [
    'Kya Qissora bachon ke liye mehfooz hai?',
    'Ji haan. App mein koi ishtehar nahi, koi tracking nahi aur koi outside link nahi. Har kahani likhi, suni aur check ki gayi hai.',
  ],
  [
    'Umar kitni honi chahiye?',
    'Kahaniyan 5 se 13 saal ke bachon ke liye likhi gayi hain, lekin poora ghar mil kar sun sakta hai.',
  ],
  [
    'Kya internet zaroori hai?',
    'Sirf pehli dafa. Us ke baad kahani phone mein mehfooz ho jati hai aur bina internet ke chalti hai.',
  ],
  [
    'Parents area mein kya hai?',
    '4-digit PIN ke peeche: kitni kahaniyan suni gayin, bache ka naam, favourites, night mode aur listening history clear karne ka option.',
  ],
  [
    'Sone se pehle sunna ho to?',
    'Sleep timer lagayein. Waqt poora hone par kahani narmi se dheemi ho kar band ho jati hai.',
  ],
  [
    'Website par poori kahani kyun nahi chalti?',
    'Website par har series ka pehla episode aadha free hai, taake aap parakh sakein. Poori kahaniyan app mein hain.',
  ],
];

export default function ParentsPage() {
  return (
    <>
      <PageHeader
        eyebrow="For parents"
        title="Parents ke liye bhi sukoon"
        lead="Aap jaante hain ke aap ka bacha kya sun raha hai — aur kya seekh raha hai."
      />

      <ParentSection />

      <Section eyebrow="FAQs" title="Walidain ke aam sawal" align="left">
        <dl className="grid gap-4 md:grid-cols-2">
          {faqs.map(([q, a]) => (
            <div key={q} className="card p-6">
              <dt className="font-display text-lg font-bold text-navy">{q}</dt>
              <dd className="mt-2 text-sm leading-relaxed text-ink-soft">
                {a}
              </dd>
            </div>
          ))}
        </dl>
      </Section>

      <CtaSection />
    </>
  );
}
