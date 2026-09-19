import type { Metadata } from 'next';
import Image from 'next/image';

import { CtaSection } from '@/components/CtaSection';
import { PageHeader } from '@/components/PageHeader';
import { Section } from '@/components/Section';

export const metadata: Metadata = {
  title: 'About Qissora',
  description:
    'Qissora is the audio story platform of Imaan & Akhlaq: Islamic ' +
    'values, good character and beautiful storytelling, made for children.',
  alternates: { canonical: '/about' },
};

const objectives = [
  ['❤️', 'Character-Centered', 'Building strong moral character by weaving Islamic values into everyday learning and behaviour.'],
  ['🎮', 'Holistic Learning', 'Curriculum, storytelling, activities and interactive tools, together in one programme.'],
  ['🕌', 'Faith Integration', 'Strengthening a child’s connection with Islamic teachings through the stories of the Prophets.'],
  ['🌟', 'Behavior Transformation', 'Courage, kindness, responsibility and integrity, in real situations.'],
];

const stages = [
  ['Foundation Stage', 'Ages 5 – 8', 'Character building through storytelling and simple activity modules.'],
  ['Interactive Stage', 'Ages 9 – 10', 'Club engagements, a focus on responsibility, and group tasks.'],
  ['Ethical Maturation', 'Ages 11 – 13', 'Real-world scenarios, peer mentoring and leadership.'],
  ['Uswah e Hasana', 'Ages 14+', 'Embodying character, leading clubs and deeper behavioural change.'],
];

export default function AboutPage() {
  return (
    <>
      <PageHeader
        eyebrow="About Qissora"
        title="A lesson in every story, with Imaan and Akhlaq"
        lead="Rooted in timeless Islamic values, Imaan & Akhlaq brings to life the journey of two siblings who guide young learners to live with courage, kindness and integrity."
      />

      <section className="section">
        <div className="grid items-center gap-10 lg:grid-cols-2">
          <Image
            src="/covers/honesty.webp"
            alt="Imaan and Akhlaq in a story illustration"
            width={800}
            height={800}
            className="w-full rounded-[var(--radius-xl2)] object-cover
              shadow-[var(--shadow-lift)]"
          />
          <div>
            <h2 className="text-3xl">Our Vision</h2>
            <p className="mt-3 text-lg leading-relaxed text-ink-soft">
              To nurture a generation of confident, responsible and virtuous
              Muslims by placing Imaan (faith) and Akhlaq (character) at the
              heart of education, so children live with courage, kindness and
              integrity in every part of life.
            </p>
            <p className="mt-4 leading-relaxed text-ink-soft">
              Qissora is the listening half of that programme. Alongside it
              sit structured books, colouring activities, games and
              school-based clubs, all built around the same two characters.
            </p>
            <div className="mt-6 rounded-[var(--radius-card)] bg-peach-tint
              p-4 text-sm font-semibold text-navy">
              🚀 Following the success of our pilots, the programme launches
              nationwide in 2026, in shaa Allah.
            </div>
          </div>
        </div>
      </section>

      <Section
        eyebrow="Core objectives"
        title="What we set out to build"
        className="mt-6"
      >
        <ul className="grid gap-5 sm:grid-cols-2">
          {objectives.map(([icon, title, body]) => (
            <li key={title} className="card p-6">
              <span aria-hidden="true" className="text-2xl">{icon}</span>
              <h3 className="mt-3 text-xl">{title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-ink-soft">
                {body}
              </p>
            </li>
          ))}
        </ul>
      </Section>

      <Section
        eyebrow="Progression focus"
        title="The programme grows with the child"
        className="bg-blush/60"
      >
        <ol className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {stages.map(([title, ages, body], i) => (
            <li key={title} className="card p-6">
              <span className="flex size-9 items-center justify-center
                rounded-full bg-pink text-sm font-bold text-white">
                {i + 1}
              </span>
              <h3 className="mt-3 text-lg">{title}</h3>
              <p className="text-xs font-bold text-orange-deep">{ages}</p>
              <p className="mt-2 text-sm leading-relaxed text-ink-soft">
                {body}
              </p>
            </li>
          ))}
        </ol>
      </Section>

      <CtaSection />
    </>
  );
}
