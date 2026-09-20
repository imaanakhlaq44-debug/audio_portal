'use client';

import Image from 'next/image';
import { useEffect, useRef } from 'react';

import { usePlayer } from '@/components/player/PlayerProvider';
import { spokenIndex } from '@/components/reader/captions';
import { useReader } from '@/components/reader/ReaderProvider';
import { coverUrl, dirOf, langAttr } from '@/data/stories';

/**
 * The reader, put away but not closed: a pill at the foot of the page with
 * the line being spoken, while the page behind it is yours again. It stands
 * in for the mini player, which hides for as long as the reader is up, so
 * there is only ever one bar down there.
 */
export function ReaderDock() {
  const { current, isPlaying, positionMs, toggle } = usePlayer();
  const { mode, restore, closeReader } = useReader();
  const lineRef = useRef<HTMLButtonElement>(null);
  const minimized = mode === 'minimized';

  // Closing the dialog hands focus back to whatever opened it, which is
  // somewhere under the dock. Bring it here, where the reader now lives.
  useEffect(() => {
    if (minimized) lineRef.current?.focus({ preventScroll: true });
  }, [minimized]);

  if (!minimized || !current) return null;

  const { series, episode } = current;
  const i = spokenIndex(episode.captions, positionMs);
  const line = episode.captions[Math.max(i, 0)]?.text ?? '';

  return (
    <div className="pointer-events-none fixed inset-x-0 bottom-0 z-50 p-3 sm:p-4">
      <div
        className="pointer-events-auto mx-auto flex w-full max-w-4xl
          items-center gap-3 rounded-[var(--radius-xl2)] border
          border-outline-soft/40 bg-white p-2 pe-3 shadow-[var(--shadow-lift)]
          sm:gap-4 sm:ps-3"
      >
        <Image
          src={coverUrl(series)}
          alt=""
          width={48}
          height={48}
          className="size-12 shrink-0 rounded-2xl object-cover"
        />

        <button
          ref={lineRef}
          type="button"
          onClick={restore}
          aria-label="Open the reader"
          className="min-w-0 flex-1 rounded-2xl px-2 py-1 text-start transition
            hover:bg-blush"
        >
          <span className="block truncate text-[11px] font-bold tracking-wider
            text-orange-deep uppercase">
            Reading
          </span>
          <span
            className="block truncate text-sm font-semibold text-navy"
            dir={dirOf(series)}
            lang={langAttr(series)}
          >
            {line}
          </span>
        </button>

        <button
          type="button"
          onClick={toggle}
          aria-label={isPlaying ? 'Pause' : 'Play'}
          className="flex size-11 shrink-0 items-center justify-center
            rounded-full bg-orange text-white shadow-[var(--shadow-soft)]
            transition hover:bg-orange-deep"
        >
          <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
            {isPlaying ? (
              <path d="M8 5h3v14H8zM13 5h3v14h-3z" />
            ) : (
              <path d="M8 5l11 7-11 7z" />
            )}
          </svg>
        </button>

        <button
          type="button"
          onClick={restore}
          aria-label="Open the reader"
          title="Open the reader"
          className="hidden size-10 shrink-0 items-center justify-center
            rounded-full text-outline transition hover:bg-blush hover:text-navy
            sm:flex"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
            <path d="M4 9V4h5M20 15v5h-5M20 9V4h-5M4 15v5h5" />
          </svg>
        </button>

        <button
          type="button"
          onClick={closeReader}
          aria-label="Close the reader"
          title="Close the reader"
          className="flex size-10 shrink-0 items-center justify-center
            rounded-full text-outline transition hover:bg-blush hover:text-navy"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" aria-hidden="true">
            <path d="M6 6l12 12M18 6L6 18" />
          </svg>
        </button>
      </div>
    </div>
  );
}
