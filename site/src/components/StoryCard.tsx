'use client';

import Image from 'next/image';
import Link from 'next/link';

import { usePlayer } from '@/components/player/PlayerProvider';
import {
  coverUrl,
  dirOf,
  episodeCountLabel,
  langAttr,
  minutes,
  themeLabel,
  totalMinutes,
} from '@/data/stories';
import type { Series } from '@/data/types';

/**
 * One series: the cover, what it is about, and a play button that starts
 * its free preview in the mini player without leaving the page.
 */
export function StoryCard({ series }: { series: Series }) {
  const { play, current, isPlaying } = usePlayer();
  const first = series.episodes[0];
  const active = current?.episode.id === first.id;

  return (
    <article
      className="card group relative flex h-full flex-col overflow-hidden
        transition hover:-translate-y-1 hover:shadow-[var(--shadow-lift)]"
    >
      <div className="relative aspect-square overflow-hidden">
        <Image
          src={coverUrl(series)}
          alt={`Cover art for ${series.title}`}
          fill
          sizes="(max-width: 640px) 70vw, (max-width: 1024px) 40vw, 260px"
          className="object-cover transition duration-500 group-hover:scale-105"
        />
        <span className="absolute left-3 top-3 rounded-full bg-white/90 px-3
          py-1 text-xs font-bold text-pink-deep">
          {themeLabel(series)}
        </span>

        <button
          type="button"
          onClick={() => play(series, first)}
          aria-label={`Play the free preview of ${series.title}`}
          className="absolute bottom-3 end-3 flex size-12 items-center
            justify-center rounded-full bg-orange text-white
            shadow-[var(--shadow-soft)] transition hover:bg-orange-deep
            hover:scale-110"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            {active && isPlaying ? (
              <path d="M8 5h3v14H8zM13 5h3v14h-3z" />
            ) : (
              <path d="M8 5l11 7-11 7z" />
            )}
          </svg>
        </button>

        <span className="absolute bottom-3 start-3 rounded-full bg-navy/80
          px-3 py-1 text-[11px] font-bold text-white">
          {minutes(first.previewEndMs ?? first.durationMs)} free
        </span>
      </div>

      <div className="flex flex-1 flex-col p-4">
        <h3 className="text-lg leading-snug" dir={dirOf(series)} lang={langAttr(series)}>
          {/* The whole card is a link; the play button sits above it. */}
          <Link href={`/stories/${series.id}`} className="after:absolute
            after:inset-0 after:content-['']">
            {series.title}
          </Link>
        </h3>
        <p
          className="mt-1 line-clamp-2 flex-1 text-sm text-ink-soft"
          dir={dirOf(series)}
          lang={langAttr(series)}
        >
          {series.description}
        </p>
        {/* Urdu counts sit next to Latin numerals, so each part is
            isolated to keep the bidi order readable. */}
        <p dir="ltr" className="mt-3 text-xs font-semibold text-orange-deep">
          <bdi lang={langAttr(series)}>{episodeCountLabel(series)}</bdi>
          {' · '}
          <bdi>{totalMinutes(series)} min</bdi>
        </p>
      </div>
    </article>
  );
}
