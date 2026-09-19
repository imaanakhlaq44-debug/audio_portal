import type { Metadata } from 'next';
import Image from 'next/image';
import Link from 'next/link';

import { CtaSection } from '@/components/CtaSection';
import { PageHeader } from '@/components/PageHeader';
import { allSeries, coverUrl, seriesById } from '@/data/stories';

export const metadata: Metadata = {
  title: 'Categories',
  description:
    'Qissora ki categories: Prophet stories, moral stories, aur honesty, ' +
    'kindness, patience, gratitude, respect aur fairness par series.',
  alternates: { canonical: '/categories' },
};

/** Each theme, the series that teaches it, and the cover to show for it. */
const themes = [
  {
    title: 'Prophet Stories',
    body: 'Hazrat Adam, Idris, Nuh, Hud aur Salih (A.S.) ki kahaniyan.',
    series: 'adam_en',
    tint: 'bg-sky-tint',
  },
  {
    title: 'Honesty',
    body: 'Sach bolna aur amanat ka khayal rakhna.',
    series: 'honesty_en',
    tint: 'bg-pink-tint',
  },
  {
    title: 'Kindness',
    body: 'Doosron ke saath narmi aur madad ka jazba.',
    series: 'kindness_en',
    tint: 'bg-peach-tint',
  },
  {
    title: 'Patience',
    body: 'Sabr, aur woh cheezein jo waqt maangti hain.',
    series: 'patience_en',
    tint: 'bg-sky-tint',
  },
  {
    title: 'Gratitude',
    body: 'Un cheezon ka shukar jin par nazar nahi jati.',
    series: 'gratitude_en',
    tint: 'bg-pink-tint',
  },
  {
    title: 'Respect',
    body: 'Har insan ki izzat aur apni izzat-e-nafs.',
    series: 'respect_en',
    tint: 'bg-peach-tint',
  },
  {
    title: 'Fairness',
    body: 'Insaf, aur sahi taraf khara hone ki himmat.',
    series: 'fairness_en',
    tint: 'bg-sky-tint',
  },
  {
    title: 'Bedtime Stories',
    body: 'Sleep timer ke saath, sone se pehle sunne ke liye.',
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
        title="Har achi aadat ke liye aik kahani"
        lead={`Anbiya ki kahaniyan aur akhlaqi series — English mein bhi aur Urdu mein bhi (${urdu} Urdu series).`}
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
