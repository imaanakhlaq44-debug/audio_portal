import type { Metadata } from 'next';
import Image from 'next/image';

import { CharacterSection } from '@/components/CharacterSection';
import { CtaSection } from '@/components/CtaSection';
import { PageHeader } from '@/components/PageHeader';
import { Section } from '@/components/Section';
import { StoryGrid } from '@/components/StoryGrid';
import { allSeries } from '@/data/stories';

export const metadata: Metadata = {
  title: 'Imaan & Akhlaq',
  description:
    'Imaan and Akhlaq are the two characters at the heart of Qissora — a ' +
    'sister and a brother children learn alongside in every story.',
  alternates: { canonical: '/imaan-akhlaq' },
};

const moments = [
  ['kindness', 'Sharing a lunchbox in the park'],
  ['fairness', 'Standing up for what is fair'],
  ['patience', 'Finishing something slowly, and properly'],
  ['gratitude', 'Noticing the blessings of an ordinary day'],
] as const;

export default function CharactersPage() {
  const withCharacters = allSeries
    .filter((s) => s.language === 'english' && s.category === 'moral')
    .slice(0, 4);

  return (
    <>
      <PageHeader
        eyebrow="Meet the characters"
        title="Imaan &amp; Akhlaq"
        lead="A sister and a brother who appear in every story: Imaan thinks things through, and Akhlaq wants to know why."
      />

      <CharacterSection />

      <Section
        eyebrow="From the stories"
        title="The moments children remember"
        className="bg-blush/60"
      >
        <ul className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {moments.map(([cover, caption]) => (
            <li key={cover} className="card overflow-hidden">
              <Image
                src={`/covers/${cover}.webp`}
                alt={caption}
                width={800}
                height={800}
                className="aspect-square w-full object-cover"
              />
              <p className="p-4 text-sm font-semibold text-navy">{caption}</p>
            </li>
          ))}
        </ul>
      </Section>

      <Section
        eyebrow="Their stories"
        title="Listen along with Imaan and Akhlaq"
      >
        <StoryGrid series={withCharacters} />
      </Section>

      <CtaSection />
    </>
  );
}
