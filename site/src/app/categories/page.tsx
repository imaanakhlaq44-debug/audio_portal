import type { Metadata } from 'next';
import Image from 'next/image';
import Link from 'next/link';

import { CtaSection } from '@/components/CtaSection';
import { PageHeader } from '@/components/PageHeader';
import { allSeries, coverUrl, prophetNames, seriesById } from '@/data/stories';

export const metadata: Metadata = {
  title: 'Categories',
  description:
    'Qissora categories: stories of the Prophets, and moral series about ' +
    'honesty, kindness, patience, gratitude, respect and fairness.',
  alternates: { canonical: '/categories' },
};

/** Each theme, the series that teaches it, and the cover to show for it. */
const themes = [
  {
    title: 'Prophet Stories',
    body: `Hazrat ${prophetNames()} (A.S.).`,
    series: 'adam_en',
    tint: 'bg-sky-tint',
  },
  {
    title: 'Honesty',
    body: 'Telling the truth, and keeping what you were trusted with.',
    series: 'honesty_en',
    tint: 'bg-pink-tint',
  },
  {
    title: 'Kindness',
    body: 'Gentleness towards others, and the wish to help.',
    series: 'kindness_en',
    tint: 'bg-peach-tint',
  },
  {
    title: 'Patience',
    body: 'Sabr, and the things that simply take time.',
    series: 'patience_en',
    tint: 'bg-sky-tint',
  },
  {
    title: 'Gratitude',
    body: 'Noticing the everyday blessings nobody stops to see.',
    series: 'gratitude_en',
    tint: 'bg-pink-tint',
  },
  {
    title: 'Respect',
    body: 'The dignity of every person, and your own self-respect.',
    series: 'respect_en',
    tint: 'bg-peach-tint',
  },
  {
    title: 'Fairness',
    body: 'Justice, and the courage to stand on the right side.',
    series: 'fairness_en',
    tint: 'bg-sky-tint',
  },
  {
    title: 'Bedtime Stories',
    body: 'Gentle listening before sleep, with the sleep timer on.',
    series: 'gratitude_ur',
    tint: 'bg-pink-tint',
  },
];

export default function CategoriesPage() {
  const urdu = allSeries.filter((s) => s.language === 'urdu').length;

  return (
    <>
      <PageHeader
        eyebrow="Categories"
        title="A story for every good habit"
        lead={`Stories of the Prophets and series about everyday values — in English, and ${urdu} of them in Urdu.`}
      />

      <section className="section pb-6">
        <ul className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {themes.map((t) => {
            const series = seriesById(t.series);
            return (
              <li key={t.title}>
                <Link
                  href={series ? `/stories/${series.id}` : '/stories'}
                  className={`group flex h-full flex-col overflow-hidden
                    rounded-[var(--radius-card)] ${t.tint} transition
                    hover:-translate-y-1 hover:shadow-[var(--shadow-lift)]`}
                >
                  {series && (
                    <div className="relative aspect-[4/3] overflow-hidden">
                      <Image
                        src={coverUrl(series)}
                        alt=""
                        fill
                        sizes="(max-width: 640px) 90vw, 300px"
                        className="object-cover transition duration-500
                          group-hover:scale-105"
                      />
                    </div>
                  )}
                  <div className="p-5">
                    <h2 className="text-xl">{t.title}</h2>
                    <p className="mt-1 text-sm text-ink-soft">{t.body}</p>
                  </div>
                </Link>
              </li>
            );
          })}
        </ul>
      </section>

      <CtaSection />
    </>
  );
}
