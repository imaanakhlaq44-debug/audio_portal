import type { Metadata } from 'next';
import Image from 'next/image';
import Link from 'next/link';
import { notFound } from 'next/navigation';

import { AudioPlayer } from '@/components/AudioPlayer';
import { CtaSection } from '@/components/CtaSection';
import { StoryGrid } from '@/components/StoryGrid';
import {
  allSeries,
  categoryLabel,
  clock,
  coverUrl,
  dirOf,
  episodeCountLabel,
  langAttr,
  languageLabel,
  seriesById,
  themeLabel,
  totalMinutes,
} from '@/data/stories';
import { appStoreLinks, siteUrl } from '@/lib/site';

export function generateStaticParams() {
  return allSeries.map((s) => ({ id: s.id }));
}

export async function generateMetadata({
  params,
}: {
  params: Promise<{ id: string }>;
}): Promise<Metadata> {
  const series = seriesById((await params).id);
  if (!series) return {};
  return {
    title: series.title,
    description: `${series.description} ${episodeCountLabel(series)} in ${
      languageLabel[series.language]
    } on Qissora.`,
    alternates: { canonical: `/stories/${series.id}` },
    openGraph: {
      title: `${series.title} — Qissora`,
      description: series.description,
      images: [{ url: coverUrl(series), width: 800, height: 800 }],
    },
  };
}

export default async function StoryPage({
  params,
}: {
  params: Promise<{ id: string }>;
}) {
  const series = seriesById((await params).id);
  if (!series) notFound();

  const dir = dirOf(series);
  const lang = langAttr(series);
  const related = allSeries
    .filter((s) => s.id !== series.id && s.language === series.language)
    .slice(0, 4);

  // Search engines understand a series of audio episodes as an AudioObject
  // collection; this is what shows a rich result.
  const jsonLd = {
    '@context': 'https://schema.org',
    '@type': 'AudiobookSeries',
    name: series.title,
    description: series.description,
    inLanguage: series.language === 'urdu' ? 'ur' : 'en',
    numberOfEpisodes: series.episodes.length,
    image: `${siteUrl}${coverUrl(series)}`,
    publisher: { '@type': 'Organization', name: 'Imaan & Akhlaq' },
  };

  return (
    <>
      <script
        type="application/ld+json"
        dangerouslySetInnerHTML={{ __html: JSON.stringify(jsonLd) }}
      />

      <section className="section grid gap-10 py-12 lg:grid-cols-[minmax(0,360px)_1fr]
        lg:py-16">
        <div>
          <Image
            src={coverUrl(series)}
            alt={`Cover art for ${series.title}`}
            width={800}
            height={800}
            priority
            className="w-full rounded-[var(--radius-xl2)] object-cover
              shadow-[var(--shadow-lift)]"
          />
        </div>

        <div>
          <div className="flex flex-wrap gap-2">
            <span className="eyebrow">{categoryLabel[series.category]}</span>
            <span className="inline-flex items-center rounded-full
              bg-peach-tint px-4 py-1.5 text-xs font-bold tracking-wider
              text-orange-deep uppercase">
              {themeLabel(series)}
            </span>
            <span className="inline-flex items-center rounded-full
              bg-sky-tint px-4 py-1.5 text-xs font-bold tracking-wider
              text-blue uppercase">
              {languageLabel[series.language]}
            </span>
          </div>

          <h1 className="mt-5 text-4xl sm:text-5xl" dir={dir} lang={lang}>
            {series.title}
          </h1>
          <p className="mt-3 text-lg text-ink-soft" dir={dir} lang={lang}>
            {series.description}
          </p>
          <p
            dir="ltr"
            className="mt-2 text-sm font-semibold text-orange-deep"
          >
            <bdi lang={lang}>{episodeCountLabel(series)}</bdi>
            {' · '}
            <bdi>{totalMinutes(series)} min</bdi>
            {' · Narrated by Imaan & Akhlaq'}
          </p>

          <div className="mt-8">
            <AudioPlayer
              series={series}
              episode={series.episodes[0]}
              readAlongOpen
            />
          </div>
        </div>
      </section>

      <section className="section pb-6">
        <h2 className="text-2xl">Episodes</h2>
        <ol className="mt-5 space-y-3">
          {series.episodes.map((e, i) => {
            const free = e.previewEndMs != null;
            return (
              <li
                key={e.id}
                className="card flex items-center gap-4 p-4"
              >
                <span
                  className={`flex size-10 shrink-0 items-center justify-center
                    rounded-full text-sm font-bold ${
                      free
                        ? 'bg-peach-tint text-orange-deep'
                        : 'bg-blush text-outline'
                    }`}
                >
                  {i + 1}
                </span>
                <div className="min-w-0 flex-1">
                  <p
                    className="truncate font-semibold text-navy"
                    dir={dir}
                    lang={lang}
                  >
                    {e.title}
                  </p>
                  <p className="text-xs text-ink-soft">
                    {clock(e.durationMs)}
                    {free && ' · first half free'}
                  </p>
                </div>
                {free ? (
                  <span className="rounded-full bg-green/10 px-3 py-1 text-xs
                    font-bold text-green">
                    FREE PREVIEW
                  </span>
                ) : (
                  <span
                    className="inline-flex items-center gap-1 rounded-full
                      bg-pink-tint px-3 py-1 text-xs font-bold text-pink-deep"
                  >
                    <svg width="12" height="12" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                      <path d="M17 9V7a5 5 0 10-10 0v2H5v12h14V9zM9 7a3 3 0 116 0v2H9z" />
                    </svg>
                    In the app
                  </span>
                )}
              </li>
            );
          })}
        </ol>

        <div className="mt-8 rounded-[var(--radius-card)] bg-blush p-6
          text-center">
          <p className="text-base font-semibold text-navy">
            Listen to the whole series, start to finish, in the Qissora app.
          </p>
          <a href={appStoreLinks.googlePlay} className="btn-primary mt-4">
            Get it on Google Play
          </a>
        </div>
      </section>

      <section className="section py-12">
        <div className="flex items-end justify-between gap-4">
          <h2 className="text-2xl">More to listen to</h2>
          <Link
            href="/stories"
            className="text-sm font-bold text-pink-deep hover:underline"
          >
            All stories
          </Link>
        </div>
        <div className="mt-6">
          <StoryGrid series={related} />
        </div>
      </section>

      <CtaSection />
    </>
  );
}
