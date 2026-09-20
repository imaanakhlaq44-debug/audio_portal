import Link from 'next/link';

import { CharacterSection } from '@/components/CharacterSection';
import { CtaSection } from '@/components/CtaSection';
import { FeaturedPlayer } from '@/components/FeaturedPlayer';
import { Hero } from '@/components/Hero';
import { HowItWorks } from '@/components/HowItWorks';
import { ParentSection } from '@/components/ParentSection';
import { ParentStrip } from '@/components/ParentStrip';
import { Section } from '@/components/Section';
import { StoryRail } from '@/components/StoryRail';
import { WhyQissora } from '@/components/WhyQissora';
import { allSeries, seriesById, seriesInCategory, totalMinutes } from '@/data/stories';

const featured = seriesById('kindness_en') ?? allSeries[0];

const prophets = seriesInCategory('prophets', 'english');
const moral = seriesInCategory('moral', 'english');
const urdu = allSeries.filter((s) => s.language === 'urdu');
// A shelf for a short sitting: the series that finish soonest.
const shortest = [...allSeries]
  .filter((s) => s.language === 'english')
  .sort((a, b) => totalMinutes(a) - totalMinutes(b))
  .slice(0, 6);

export default function HomePage() {
  return (
    <>
      <Hero featured={featured} />

      {/* Straight into a story: the player docks at the bottom of the page
          and keeps playing while you browse the shelves below. */}
      <Section
        eyebrow="Listen free, right here"
        title="Start with one story"
        lead="The first episode of every series is free to sample. Press play and keep browsing — it follows you down the page."
        className="bg-blush/60"
      >
        <div className="mx-auto max-w-3xl">
          <FeaturedPlayer series={featured} />
        </div>
      </Section>

      <div className="pt-6">
        <StoryRail
          title="Stories of the Prophets"
          subtitle="Hazrat Adam, Idris, Nuh, Hud and Salih (A.S.)."
          series={prophets}
          href="/categories"
        />
        <StoryRail
          title="Values to grow up with"
          subtitle="Honesty, kindness, patience, gratitude, respect and fairness."
          series={moral}
          href="/stories"
        />
        <StoryRail
          title="اردو کہانیاں"
          subtitle="Every story, narrated in Urdu as well."
          series={urdu}
          href="/stories"
        />
        <StoryRail
          title="Short enough for one sitting"
          subtitle="Series you can finish in an evening."
          series={shortest}
          href="/stories"
        />

        <div className="section mt-6 text-center">
          <Link href="/stories" className="btn-primary">
            Browse all 22 series
          </Link>
        </div>
      </div>

      <WhyQissora />
      <HowItWorks />
      <CharacterSection />
      <ParentStrip />
      <ParentSection />
      <CtaSection />
    </>
  );
}
