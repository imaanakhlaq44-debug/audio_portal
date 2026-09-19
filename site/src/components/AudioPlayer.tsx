'use client';

import Image from 'next/image';
import { useEffect, useRef, useState } from 'react';

import { audioUrl, clock, coverUrl, dirOf, langAttr } from '@/data/stories';
import type { Episode, Series } from '@/data/types';
import { appStoreLinks } from '@/lib/site';

interface Props {
  series: Series;
  episode: Episode;
  /** Bigger artwork and title, for the story detail page. */
  size?: 'compact' | 'full';
}

/**
 * The app's Now Playing card, on the web: cover, play button, scrubber and
 * the same free preview limit. The website plays episode one up to its
 * halfway point and then invites the listener into the app, exactly as the
 * app does for a listener without Premium.
 */
export function AudioPlayer({ series, episode, size = 'full' }: Props) {
  const audioRef = useRef<HTMLAudioElement>(null);
  const [playing, setPlaying] = useState(false);
  const [position, setPosition] = useState(0);
  const [reachedLimit, setReachedLimit] = useState(false);

  const limitMs = episode.previewEndMs;
  const endMs = limitMs ?? episode.durationMs;

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

  function seek(event: React.ChangeEvent<HTMLInputElement>) {
    const el = audioRef.current;
    if (!el) return;
    const ms = Math.min(Number(event.target.value), endMs);
    el.currentTime = ms / 1000;
    setPosition(ms);
    if (limitMs == null || ms < limitMs) setReachedLimit(false);
  }

  const progress = endMs > 0 ? (position / endMs) * 100 : 0;
  const coverSize = size === 'full' ? 132 : 92;

  return (
    <div
      className="card w-full overflow-hidden p-4 sm:p-6"
      aria-label={`Player for ${episode.title}`}
    >
      <div className="flex flex-col gap-5 sm:flex-row sm:items-center">
        <Image
          src={coverUrl(series)}
          alt={`Cover art for ${series.title}`}
          width={coverSize}
          height={coverSize}
          className="mx-auto size-28 rounded-[var(--radius-card)] object-cover
            sm:mx-0 sm:size-32"
        />

        <div className="min-w-0 flex-1">
          <p className="text-xs font-bold tracking-wider text-orange-deep
            uppercase">
            {reachedLimit ? 'End of free preview' : 'Free preview'}
          </p>
          <h3
            className="mt-1 truncate text-xl"
            dir={dirOf(series)}
            lang={langAttr(series)}
          >
            {episode.title}
          </h3>
          <p
            className="mt-0.5 truncate text-sm text-ink-soft"
            dir={dirOf(series)}
            lang={langAttr(series)}
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
                onChange={seek}
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

      {reachedLimit && (
        <div className="mt-5 flex flex-col items-start gap-3 rounded-2xl
          bg-pink-tint p-4 sm:flex-row sm:items-center sm:justify-between">
          <p className="text-sm font-semibold text-navy">
            Yeh free preview yahan tak thi. Poori kahani app mein sunein.
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
