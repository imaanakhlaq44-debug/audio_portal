'use client';

import Image from 'next/image';
import { useState } from 'react';

import { usePlayer } from '@/components/player/PlayerProvider';
import { ReadAlong } from '@/components/ReadAlong';
import { clock, coverUrl, dirOf, langAttr } from '@/data/stories';
import type { Episode, Series } from '@/data/types';
import { appStoreLinks } from '@/lib/site';

interface Props {
  series: Series;
  episode: Episode;
  /** Open the read-along text straight away, as on a story's own page. */
  readAlongOpen?: boolean;
}

/**
 * The app's Now Playing card, on the web: cover, play button, scrubber and
 * read-along text. Sound comes from the one player the whole site shares,
 * so the story keeps going in the bar at the bottom as the reader scrolls
 * on. Playback stops at the end of the free preview, exactly as the app
 * stops a listener without Premium.
 */
export function AudioPlayer({ series, episode, readAlongOpen = false }: Props) {
  const player = usePlayer();
  const [reading, setReading] = useState(readAlongOpen);

  const active = player.current?.episode.id === episode.id;
  const positionMs = active ? player.positionMs : 0;
  const endMs = episode.previewEndMs ?? episode.durationMs;
  const playing = active && player.isPlaying;
  const dir = dirOf(series);
  const lang = langAttr(series);
  const hasText = episode.captions.length > 0;

  const progress = endMs > 0 ? (positionMs / endMs) * 100 : 0;

  function start() {
    if (active) player.toggle();
    else player.play(series, episode);
  }

  function seek(ms: number) {
    if (!active) player.play(series, episode);
    player.seek(ms);
  }

  return (
    <div
      className="card w-full overflow-hidden p-4 sm:p-6"
      aria-label={`Player for ${episode.title}`}
    >
      <div className="flex flex-col gap-5 sm:flex-row sm:items-center">
        <Image
          src={coverUrl(series)}
          alt={`Cover art for ${series.title}`}
          width={132}
          height={132}
          className="mx-auto size-28 rounded-[var(--radius-card)] object-cover
            sm:mx-0 sm:size-32"
        />

        <div className="min-w-0 flex-1">
          <p className="text-xs font-bold tracking-wider text-orange-deep
            uppercase">
            {active && player.reachedLimit
              ? 'End of free preview'
              : 'Free preview'}
          </p>
          <h3 className="mt-1 truncate text-xl" dir={dir} lang={lang}>
            {episode.title}
          </h3>
          <p
            className="mt-0.5 truncate text-sm text-ink-soft"
            dir={dir}
            lang={lang}
          >
            {series.title} · Narrated by Imaan &amp; Akhlaq
          </p>

          <div className="mt-4 flex items-center gap-4">
            <span className="relative inline-flex">
              {playing && (
                <span
                  aria-hidden="true"
                  className="absolute inset-0 rounded-full bg-orange/40
                    animate-[var(--animate-pulse-ring)]"
                />
              )}
              <button
                type="button"
                onClick={start}
                aria-label={playing ? 'Pause' : 'Play'}
                className="relative flex size-14 items-center justify-center
                  rounded-full bg-orange text-white shadow-[var(--shadow-soft)]
                  transition hover:bg-orange-deep"
              >
                <svg width="24" height="24" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  {playing ? (
                    <path d="M8 5h3v14H8zM13 5h3v14h-3z" />
                  ) : (
                    <path d="M8 5l11 7-11 7z" />
                  )}
                </svg>
              </button>
            </span>

            <div className="flex-1">
              <input
                type="range"
                min={0}
                max={endMs}
                value={positionMs}
                onChange={(e) => seek(Number(e.target.value))}
                aria-label="Playback position"
                className="h-2 w-full cursor-pointer appearance-none
                  rounded-full accent-pink"
                style={{
                  background:
                    `linear-gradient(to right, var(--color-pink) ` +
                    `${progress}%, var(--color-pink-tint) ${progress}%)`,
                }}
              />
              <div className="mt-1 flex justify-between text-xs text-ink-soft
                tabular-nums">
                <span>{clock(positionMs)}</span>
                <span>{clock(endMs)} preview</span>
              </div>
            </div>
          </div>
        </div>
      </div>

      {hasText && (
        <div className="mt-5 border-t border-outline-soft/40 pt-4">
          <button
            type="button"
            onClick={() => setReading((v) => !v)}
            aria-expanded={reading}
            className="flex w-full items-center gap-2 text-sm font-bold
              text-pink-deep"
          >
            <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
              <path d="M4 5h7v14H4zM13 5h7v14h-7z" />
            </svg>
            {reading ? 'Hide the words' : 'Read along'}
            <svg
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="currentColor"
              aria-hidden="true"
              className={`ms-auto transition ${reading ? 'rotate-180' : ''}`}
            >
              <path d="M7 10l5 5 5-5z" />
            </svg>
          </button>

          {reading && (
            <div className="mt-3">
              <ReadAlong
                captions={episode.captions}
                positionMs={positionMs}
                dir={dir}
                lang={lang}
                onSeek={seek}
              />
              <p className="mt-3 rounded-xl bg-blush px-3 py-2 text-xs
                text-ink-soft">
                The words follow the narration. Tap any line to jump there.
                The rest of the story continues in the app.
              </p>
            </div>
          )}
        </div>
      )}

      {active && player.reachedLimit && (
        <div className="mt-5 flex flex-col items-start gap-3 rounded-2xl
          bg-pink-tint p-4 sm:flex-row sm:items-center sm:justify-between">
          <p className="text-sm font-semibold text-navy">
            That is the end of the free preview. Hear the whole story in the app.
          </p>
          <a href={appStoreLinks.googlePlay} className="btn-primary text-sm">
            Open in the app
          </a>
        </div>
      )}
    </div>
  );
}
