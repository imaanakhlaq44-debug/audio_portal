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
    'Imaan aur Akhlaq Qissora ke do kirdar hain — ek behen aur ek bhai, ' +
    'jin ke saath bachay har kahani mein kuch naya seekhte hain.',
  alternates: { canonical: '/imaan-akhlaq' },
};

const moments = [
  ['kindness', 'Park mein apna lunch baant kar'],
  ['fairness', 'Insaf ke liye khare ho kar'],
  ['patience', 'Sabr se aik kaam mukammal kar ke'],
  ['gratitude', 'Un cheezon ka shukar ada kar ke jo roz milti hain'],
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
        lead="Do behen bhai jo har kahani mein saath hote hain: Imaan soch samajh kar faisla karti hai, Akhlaq har cheez ka sabab poochhta hai."
      />

      <CharacterSection />

      <Section
        eyebrow="Kahaniyon se"
        title="Woh lamhe jo yaad reh jate hain"
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
        eyebrow="Unki kahaniyan"
        title="Imaan aur Akhlaq ke saath sunein"
      >
        <StoryGrid series={withCharacters} />
      </Section>

      <CtaSection />
    </>
  );
}
