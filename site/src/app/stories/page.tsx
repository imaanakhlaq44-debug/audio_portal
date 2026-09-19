import type { Metadata } from 'next';

import { CtaSection } from '@/components/CtaSection';
import { PageHeader } from '@/components/PageHeader';
import { StoryBrowser } from '@/components/StoryBrowser';

export const metadata: Metadata = {
  title: 'Stories',
  description:
    'Qissora ki saari kahaniyan: Anbiya ki kahaniyan aur akhlaqi series, ' +
    'English aur Urdu mein. Har series ka pehla episode free sunein.',
  alternates: { canonical: '/stories' },
};

export default function StoriesPage() {
  return (
    <>
      <PageHeader
        eyebrow="Explore stories"
        title="Saari kahaniyan aik jagah"
        lead="22 series, 164 episodes. Zabaan chunein aur sunna shuru karein — har series ka pehla episode free hai."
      />
      <section className="section pb-10">
        <StoryBrowser />
      </section>
      <CtaSection />
    </>
  );
}
