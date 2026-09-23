'use client';

import { usePlayer } from '@/components/player/PlayerProvider';
import { clock } from '@/data/stories';
import type { Episode, Series } from '@/data/types';

/**
 * The spoken welcome that opens a series: one tap and it plays in full.
 *
 * It is deliberately smaller than the episode player — no scrubber, no
 * read-along — because it is a signpost into the series rather than a story
 * of its own. Sound goes through the same shared player, so it keeps playing
 * while the reader scrolls on.
 */
export function MeetTheSeries({
  series,
  welcome,
}: {
  series: Series;
  welcome: Episode;
}) {
  const player = usePlayer();
  const active = player.current?.episode.id === welcome.id;
  const playing = active && player.isPlaying;
  const urdu = series.language === 'urdu';

  return (
    <button
      type="button"
      onClick={() => (active ? player.toggle() : player.play(series, welcome))}
      aria-label={
        playing
          ? 'Pause the series welcome'
          : 'Play the series welcome, free for everyone'
      }
      className="card flex w-full items-center gap-4 p-4 text-start
        transition hover:-translate-y-0.5 hover:shadow-[var(--shadow-glow)]"
    >
      <span className="flex size-12 shrink-0 items-center justify-center
        rounded-full bg-orange text-white">
        <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
          {playing ? (
            <path d="M8 5h3v14H8zM13 5h3v14h-3z" />
          ) : (
            <path d="M8 5l11 7-11 7z" />
          )}
        </svg>
      </span>
      <span className="min-w-0" dir={urdu ? 'rtl' : 'ltr'} lang={urdu ? 'ur' : 'en'}>
        <span className="block font-bold text-navy">
          {urdu ? 'سلسلے کا تعارف' : 'Meet the series'}
        </span>
        <span className="mt-0.5 block text-sm text-ink-soft">
          {urdu
            ? 'اس سلسلے میں کیا ہے — سب کے لیے مفت'
            : 'What this series is about — free for everyone'}
          {' · '}
          <bdi className="tabular-nums">{clock(welcome.durationMs)}</bdi>
        </span>
      </span>
    </button>
  );
}
