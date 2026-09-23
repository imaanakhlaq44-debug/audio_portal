import type { Metadata } from 'next';

import { CtaSection } from '@/components/CtaSection';
import { PageHeader } from '@/components/PageHeader';
import { ParentSection } from '@/components/ParentSection';
import { Section } from '@/components/Section';

export const metadata: Metadata = {
  title: 'For Parents',
  description:
    'Qissora for parents: safe content, no ads, no tracking, a ' +
    'PIN-protected parents area, a sleep timer and listening stats.',
  alternates: { canonical: '/parents' },
};

const faqs = [
  [
    'Is Qissora safe for children?',
    'Yes. There are no ads, no tracking and no links out of the app. Every story is written, narrated and checked by our team.',
  ],
  [
    'Which ages is it for?',
    'The stories are written for children aged 5 to 13, and they are lovely for the whole family to listen to together.',
  ],
  [
    'Is the internet needed?',
    'Only the first time a story plays. After that it is kept on the phone and plays again without the internet.',
  ],
  [
    'What is in the parents area?',
    'Behind a 4-digit PIN: how much your child has listened to, their name, favourites, night mode, and a way to clear listening history.',
  ],
  [
    'What about listening at bedtime?',
    'Set the sleep timer. When the time is up, the story fades out gently instead of stopping abruptly.',
  ],
  [
    'Why does the website not play the whole story?',
    'The website plays the first half of episode one so you can try before you decide. The complete stories live in the app.',
  ],
];

export default function ParentsPage() {
  return (
    <>
      <PageHeader
        eyebrow="For parents"
        title="Peace of mind for parents too"
        lead="You always know what your child is listening to — and what they are learning from it."
      />

      <ParentSection />

      <Section eyebrow="FAQs" title="Questions parents ask" align="left">
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
