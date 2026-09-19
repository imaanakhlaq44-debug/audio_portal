import Link from 'next/link';

import { AudioPlayer } from '@/components/AudioPlayer';
import { CharacterSection } from '@/components/CharacterSection';
import { CtaSection } from '@/components/CtaSection';
import { Hero } from '@/components/Hero';
import { HowItWorks } from '@/components/HowItWorks';
import { ParentSection } from '@/components/ParentSection';
import { Section } from '@/components/Section';
import { StoryGrid } from '@/components/StoryGrid';
import { WhyQissora } from '@/components/WhyQissora';
import { allSeries, seriesById } from '@/data/stories';

// The story the homepage lets people hear: kindness, in English.
const featured = seriesById('kindness_en') ?? allSeries[0];

export default function HomePage() {
  return (
    <>
      <Hero />

      <Section
        eyebrow="Sun kar dekhein"
        title="Aik kahani, abhi"
        lead="Har series ka pehla episode yahan free sunein. Poori kahani app mein chalti hai."
        className="bg-blush/60"
      >
        <div className="mx-auto max-w-3xl">
          <AudioPlayer series={featured} episode={featured.episodes[0]} />
        </div>
      </Section>

      <Section
        eyebrow="Explore stories"
        title="22 series, English aur Urdu mein"
        lead="Anbiya ki kahaniyan aur akhlaqi kahaniyan, dono zabaanon mein."
      >
        <StoryGrid series={allSeries.slice(0, 8)} />
        <div className="mt-10 text-center">
          <Link href="/stories" className="btn-primary">
            Saari kahaniyan dekhein
          </Link>
        </div>
      </Section>

      <WhyQissora />
      <HowItWorks />
      <CharacterSection />
      <ParentSection />
      <CtaSection />
    </>
  );
}
