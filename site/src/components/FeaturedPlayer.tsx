'use client';

import Image from 'next/image';
import Link from 'next/link';

import { usePlayer } from '@/components/player/PlayerProvider';
import { clock, coverUrl, dirOf, langAttr, minutes } from '@/data/stories';
import type { Series } from '@/data/types';

/**
 * The big "press play" card. Playback itself lives in the mini player, so
 * the story carries on while the reader scrolls through the shelves.
 */
export function FeaturedPlayer({ series }: { series: Series }) {
  const { play, current, isPlaying, toggle } = usePlayer();
  const episode = series.episodes[0];
  const active = current?.episode.id === episode.id;
  const previewMs = episode.previewEndMs ?? episode.durationMs;

  return (
    <div className="card flex flex-col items-center gap-6 p-5 text-center
      sm:flex-row sm:p-6 sm:text-start">
      <div className="relative">
        <span
          aria-hidden="true"
          className={`absolute inset-0 rounded-[var(--radius-xl2)] bg-pink/30
            ${active && isPlaying ? 'animate-[var(--animate-pulse-ring)]' : ''}`}
        />
        <Image
          src={coverUrl(series)}
          alt={`Cover art for ${series.title}`}
          width={220}
          height={220}
          className="relative size-40 rounded-[var(--radius-xl2)] object-cover
            sm:size-52"
        />
      </div>

      <div className="min-w-0 flex-1">
        <p className="text-xs font-bold tracking-wider text-orange-deep
          uppercase">
          Free preview · {minutes(previewMs)}
        </p>
        <h3 className="mt-2 text-2xl" dir={dirOf(series)} lang={langAttr(series)}>
          {episode.title}
        </h3>
        <p className="mt-1 text-sm text-ink-soft" dir={dirOf(series)} lang={langAttr(series)}>
          {series.title} · Narrated by Imaan &amp; Akhlaq
        </p>

        <div className="mt-5 flex flex-wrap items-center justify-center gap-3
          sm:justify-start">
          <button
            type="button"
            onClick={() => (active ? toggle() : play(series, episode))}
            className="btn-secondary"
          >
            <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              {active && isPlaying ? (
                <path d="M8 5h3v14H8zM13 5h3v14h-3z" />
              ) : (
                <path d="M8 5l11 7-11 7z" />
              )}
            </svg>
            {active && isPlaying ? 'Pause the story' : 'Play the story'}
          </button>
          <Link href={`/stories/${series.id}`} className="btn-ghost">
            Read along
          </Link>
          <span className="text-xs text-ink-soft tabular-nums">
            {clock(previewMs)} free
          </span>
        </div>
      </div>
    </div>
  );
}
