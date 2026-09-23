import Link from 'next/link';

import { CharacterSection } from '@/components/CharacterSection';
import { CtaSection } from '@/components/CtaSection';
import { Hero } from '@/components/Hero';
import { HowItWorks } from '@/components/HowItWorks';
import { ParentSection } from '@/components/ParentSection';
import { ParentStrip } from '@/components/ParentStrip';
import { StoryRail } from '@/components/StoryRail';
import { WhyQissora } from '@/components/WhyQissora';
import {
  allSeries,
  catalogue,
  prophetNames,
  seriesById,
  seriesInCategory,
  totalMinutes,
} from '@/data/stories';

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

      {/* What this is and what to do here, before anything asks the reader
          to browse: someone who has never heard of Qissora should not have
          to work the page out from a shelf of covers. */}
      <HowItWorks />
      <WhyQissora />

      <div className="pt-10 sm:pt-14">
        <StoryRail
          title="Stories of the Prophets"
          subtitle={`Hazrat ${prophetNames()} (A.S.).`}
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
            Browse all {catalogue.series} series
          </Link>
        </div>
      </div>

      <CharacterSection />
      <ParentStrip />
      <ParentSection />
      <CtaSection />
    </>
  );
}
