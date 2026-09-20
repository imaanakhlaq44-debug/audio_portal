'use client';

import { usePlayer } from '@/components/player/PlayerProvider';
import { dirOf, langAttr, minutes } from '@/data/stories';
import type { Series } from '@/data/types';

/**
 * The card tucked into the corner of the hero artwork.
 *
 * It used to be a picture of a player — a white card that said "Now playing"
 * whether or not anything was. It is the real thing now: the whole card is
 * the button, it starts the featured story's free preview in the mini player,
 * and it says what is actually happening. On a phone this is the first play
 * control on the page, which for an audio product is the point.
 */
export function HeroNowPlaying({ series }: { series: Series }) {
  const { play, toggle, current, isPlaying } = usePlayer();
  const episode = series.episodes[0];
  const active = current?.episode.id === episode.id;
  const playing = active && isPlaying;
  const previewMs = episode.previewEndMs ?? episode.durationMs;

  return (
    <button
      type="button"
      onClick={() => (active ? toggle() : play(series, episode))}
      aria-label={
        playing
          ? `Pause ${episode.title}`
          : `Play the free preview of ${episode.title}`
      }
      className="absolute -bottom-6 left-4 flex max-w-[calc(100%-2rem)]
        items-center gap-3 rounded-2xl bg-white p-3 pr-5 text-start
        shadow-[var(--shadow-lift)] transition hover:-translate-y-0.5
        hover:shadow-[var(--shadow-glow)] sm:left-8"
    >
      <span
        className={`flex size-11 shrink-0 items-center justify-center
          rounded-full bg-orange text-white
          ${playing ? 'animate-[var(--animate-pulse-ring)]' : ''}`}
      >
        <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          {playing ? (
            <path d="M8 5h3v14H8zM13 5h3v14h-3z" />
          ) : (
            <path d="M8 5l11 7-11 7z" />
          )}
        </svg>
      </span>
      <span className="min-w-0">
        <span className="block text-sm font-bold text-navy">
          {playing ? 'Now playing' : `Play free · ${minutes(previewMs)}`}
        </span>
        <span
          className="block truncate text-xs text-ink-soft"
          dir={dirOf(series)}
          lang={langAttr(series)}
        >
          {episode.title}
        </span>
      </span>
    </button>
  );
}
