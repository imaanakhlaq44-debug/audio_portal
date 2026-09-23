import type { Metadata } from 'next';

import { CtaSection } from '@/components/CtaSection';
import { PageHeader } from '@/components/PageHeader';
import { StoryBrowser } from '@/components/StoryBrowser';
import { allSeries, catalogue, listing } from '@/data/stories';

export const metadata: Metadata = {
  title: 'Stories',
  description:
    'Every Qissora story: series about the Prophets and about everyday ' +
    'values, in English and Urdu. The first episode of each is free.',
  alternates: { canonical: '/stories' },
};

export default function StoriesPage() {
  return (
    <>
      <PageHeader
        eyebrow="Explore stories"
        title="Every story in one place"
        lead={`${catalogue.series} series, ${catalogue.episodes} episodes. Pick a language and start listening — the first episode of every series is free.`}
      />
      <section className="section pb-10">
        <StoryBrowser series={listing(allSeries)} />
      </section>
      <CtaSection />
    </>
  );
}
