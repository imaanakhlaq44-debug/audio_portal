'use client';

import { useEffect, useRef } from 'react';

import type { Caption } from '@/data/types';

interface Props {
  captions: Caption[];
  /** Where playback is, so the spoken line can be highlighted. */
  positionMs: number;
  dir: 'ltr' | 'rtl';
  lang: string;
  /** Jump the audio to a line the reader taps. */
  onSeek?: (ms: number) => void;
}

/**
 * The story in words, following the narration line by line — the app's
 * read-along, on the web. Only the free preview has text, so this ends
 * where the preview does.
 */
export function ReadAlong({ captions, positionMs, dir, lang, onSeek }: Props) {
  const activeRef = useRef<HTMLLIElement>(null);
  const listRef = useRef<HTMLOListElement>(null);

  const activeIndex = captions.findIndex(
    (c) => positionMs >= c.startMs && positionMs < c.endMs,
  );

  // Keep the spoken line in view, but only scroll the list itself so the
  // page does not jump under the reader.
  useEffect(() => {
    const line = activeRef.current;
    const list = listRef.current;
    if (!line || !list) return;
    const top = line.offsetTop - list.clientHeight / 2 + line.clientHeight / 2;
    list.scrollTo({ top, behavior: 'smooth' });
  }, [activeIndex]);

  if (captions.length === 0) return null;

  return (
    <ol
      ref={listRef}
      dir={dir}
      lang={lang}
      className="max-h-[26rem] space-y-1 overflow-y-auto pr-1"
    >
      {captions.map((c, i) => {
        const active = i === activeIndex;
        const spoken = positionMs >= c.endMs;
        return (
          <li key={`${c.startMs}-${i}`} ref={active ? activeRef : undefined}>
            <button
              type="button"
              onClick={() => onSeek?.(c.startMs)}
              aria-current={active ? 'true' : undefined}
              className={`w-full rounded-xl px-3 py-2 text-start text-base
                leading-relaxed transition ${
                  active
                    ? 'bg-pink-tint font-semibold text-navy'
                    : spoken
                      ? 'text-ink-soft hover:bg-blush'
                      : 'text-ink hover:bg-blush'
                }`}
            >
              {c.text}
            </button>
          </li>
        );
      })}
    </ol>
  );
}
