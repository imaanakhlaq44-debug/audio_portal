'use client';

import Image from 'next/image';
import { useEffect, useRef, useState } from 'react';

import { ReadAlong } from '@/components/ReadAlong';
import { audioUrl, clock, coverUrl, dirOf, langAttr } from '@/data/stories';
import type { Episode, Series } from '@/data/types';
import { appStoreLinks } from '@/lib/site';

interface Props {
  series: Series;
  episode: Episode;
  /** Open the read-along text straight away, as on a story's own page. */
  readAlongOpen?: boolean;
}

/**
 * The app's Now Playing card, on the web: cover, play button, scrubber,
 * read-along text and the same free preview limit. The website plays
 * episode one up to its halfway point and then invites the listener into
 * the app, exactly as the app does for a listener without Premium.
 */
export function AudioPlayer({
  series,
  episode,
  readAlongOpen = false,
}: Props) {
  const audioRef = useRef<HTMLAudioElement>(null);
  const [playing, setPlaying] = useState(false);
  const [position, setPosition] = useState(0);
  const [reachedLimit, setReachedLimit] = useState(false);
  const [reading, setReading] = useState(readAlongOpen);

  const limitMs = episode.previewEndMs;
  const endMs = limitMs ?? episode.durationMs;
  const dir = dirOf(series);
  const lang = langAttr(series);

  // Stop at the end of the free preview, however playback got there.
  useEffect(() => {
    const el = audioRef.current;
    if (!el || limitMs == null) return;
    const onTime = () => {
      if (el.currentTime * 1000 >= limitMs) {
        el.pause();
        el.currentTime = limitMs / 1000;
        setReachedLimit(true);
      }
    };
    el.addEventListener('timeupdate', onTime);
    return () => el.removeEventListener('timeupdate', onTime);
  }, [limitMs]);

  async function toggle() {
    const el = audioRef.current;
    if (!el) return;
    if (el.paused) {
      if (limitMs != null && el.currentTime * 1000 >= limitMs) {
        el.currentTime = 0;
        setReachedLimit(false);
      }
      await el.play().catch(() => setPlaying(false));
    } else {
      el.pause();
    }
  }

  function seekTo(ms: number) {
    const el = audioRef.current;
    if (!el) return;
    const target = Math.min(Math.max(ms, 0), endMs);
    el.currentTime = target / 1000;
    setPosition(target);
    if (limitMs == null || target < limitMs) setReachedLimit(false);
  }

  const progress = endMs > 0 ? (position / endMs) * 100 : 0;
  const hasText = episode.captions.length > 0;

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
            {reachedLimit ? 'End of free preview' : 'Free preview'}
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
                onClick={toggle}
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
                value={position}
                onChange={(e) => seekTo(Number(e.target.value))}
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
                <span>{clock(position)}</span>
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
                positionMs={position}
                dir={dir}
                lang={lang}
                onSeek={seekTo}
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

      {reachedLimit && (
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

      <audio
        ref={audioRef}
        src={audioUrl(episode)}
        preload="none"
        onPlay={() => setPlaying(true)}
        onPause={() => setPlaying(false)}
        onTimeUpdate={(e) =>
          setPosition(Math.round(e.currentTarget.currentTime * 1000))
        }
      />
    </div>
  );
}
