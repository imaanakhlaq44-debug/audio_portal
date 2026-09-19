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
        eyebrow="Have a listen"
        title="A story, right now"
        lead="The first episode of every series is free to sample here. The full story plays in the app."
        className="bg-blush/60"
      >
        <div className="mx-auto max-w-3xl">
          <AudioPlayer series={featured} episode={featured.episodes[0]} />
        </div>
      </Section>

      <Section
        eyebrow="Explore stories"
        title="22 series, in English and Urdu"
        lead="Stories of the Prophets, and series about the values children grow up with."
      >
        <StoryGrid series={allSeries.slice(0, 8)} />
        <div className="mt-10 text-center">
          <Link href="/stories" className="btn-primary">
            Browse all stories
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
