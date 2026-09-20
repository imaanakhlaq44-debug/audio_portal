'use client';

import Image from 'next/image';
import Link from 'next/link';
import { useState } from 'react';

import { usePlayer } from '@/components/player/PlayerProvider';
import { ReadAlong } from '@/components/ReadAlong';
import { clock, coverUrl, dirOf, langAttr } from '@/data/stories';
import { appStoreLinks } from '@/lib/site';

/**
 * The bar that follows you down the page while a story plays, like the
 * app's mini player. It expands into the read-along text, and says plainly
 * where the free preview ends.
 */
export function MiniPlayer() {
  const { current, isPlaying, positionMs, endMs, reachedLimit, toggle, seek, close } =
    usePlayer();
  const [open, setOpen] = useState(false);

  if (!current) return null;

  const { series, episode } = current;
  const dir = dirOf(series);
  const lang = langAttr(series);
  const progress = endMs > 0 ? (positionMs / endMs) * 100 : 0;
  const hasText = episode.captions.length > 0;

  return (
    <>
      {/* Keeps the end of the page clear of the bar. */}
      <div aria-hidden="true" className="h-28" />
      <div className="pointer-events-none fixed inset-x-0 bottom-0 z-50 p-3
        sm:p-4">
      <div className="pointer-events-auto mx-auto w-full max-w-4xl
        overflow-hidden rounded-[var(--radius-xl2)] border
        border-outline-soft/40 bg-white shadow-[var(--shadow-lift)]">
        {open && hasText && (
          <div className="border-b border-outline-soft/40 p-4">
            <ReadAlong
              captions={episode.captions}
              positionMs={positionMs}
              dir={dir}
              lang={lang}
              onSeek={seek}
            />
          </div>
        )}

        {reachedLimit && (
          <div className="flex flex-col items-start gap-2 bg-pink-tint px-4
            py-3 sm:flex-row sm:items-center sm:justify-between">
            <p className="text-sm font-semibold text-navy">
              That is the free preview. The whole story is in the app.
            </p>
            <a href={appStoreLinks.googlePlay} className="btn-primary text-xs">
              Open in the app
            </a>
          </div>
        )}

        <div className="flex items-center gap-3 p-3 sm:gap-4 sm:p-4">
          <Link href={`/stories/${series.id}`} className="shrink-0">
            <Image
              src={coverUrl(series)}
              alt={`Cover art for ${series.title}`}
              width={56}
              height={56}
              className="size-14 rounded-2xl object-cover"
            />
          </Link>

          <div className="min-w-0 flex-1">
            <p className="truncate text-sm font-bold text-navy" dir={dir} lang={lang}>
              {episode.title}
            </p>
            <p className="truncate text-xs text-ink-soft" dir={dir} lang={lang}>
              {series.title}
            </p>
            <div className="mt-2 flex items-center gap-2">
              <input
                type="range"
                min={0}
                max={endMs}
                value={positionMs}
                onChange={(e) => seek(Number(e.target.value))}
                aria-label="Playback position"
                className="h-1.5 w-full cursor-pointer appearance-none
                  rounded-full accent-pink"
                style={{
                  background:
                    `linear-gradient(to right, var(--color-pink) ` +
                    `${progress}%, var(--color-pink-tint) ${progress}%)`,
                }}
              />
              <span className="shrink-0 text-[11px] text-ink-soft tabular-nums">
                {clock(positionMs)} / {clock(endMs)}
              </span>
            </div>
          </div>

          <div className="flex shrink-0 items-center gap-1 sm:gap-2">
            {hasText && (
              <button
                type="button"
                onClick={() => setOpen((v) => !v)}
                aria-expanded={open}
                aria-label={open ? 'Hide the words' : 'Read along'}
                title={open ? 'Hide the words' : 'Read along'}
                className={`flex size-10 items-center justify-center
                  rounded-full transition ${
                    open
                      ? 'bg-pink-tint text-pink-deep'
                      : 'text-navy hover:bg-blush'
                  }`}
              >
                <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  <path d="M4 5h7v14H4zM13 5h7v14h-7z" />
                </svg>
              </button>
            )}

            <button
              type="button"
              onClick={toggle}
              aria-label={isPlaying ? 'Pause' : 'Play'}
              className="flex size-12 items-center justify-center rounded-full
                bg-orange text-white shadow-[var(--shadow-soft)] transition
                hover:bg-orange-deep"
            >
              <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                {isPlaying ? (
                  <path d="M8 5h3v14H8zM13 5h3v14h-3z" />
                ) : (
                  <path d="M8 5l11 7-11 7z" />
                )}
              </svg>
            </button>

            <button
              type="button"
              onClick={close}
              aria-label="Close the player"
              className="flex size-10 items-center justify-center rounded-full
                text-outline transition hover:bg-blush hover:text-navy"
            >
              <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.2" strokeLinecap="round" aria-hidden="true">
                <path d="M6 6l12 12M18 6L6 18" />
              </svg>
            </button>
          </div>
        </div>
      </div>
      </div>
    </>
  );
}
