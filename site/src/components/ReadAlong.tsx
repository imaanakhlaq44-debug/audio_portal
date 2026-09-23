'use client';

import { useCallback, useEffect, useMemo, useRef, useState } from 'react';

import { spokenIndex } from '@/components/reader/captions';
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

/** How long a reader who scrolls away is left alone, in milliseconds. */
const RESUME_AFTER = 6000;

/**
 * Scrolls the list — and only the list — so the line sits in its middle.
 *
 * Measured from rectangles rather than `offsetTop`, which counts from
 * whichever ancestor happens to be positioned and so handed this a
 * page-sized number.
 */
function centre(
  list: HTMLElement,
  line: HTMLElement,
  behavior: ScrollBehavior,
) {
  const lineRect = line.getBoundingClientRect();
  const listRect = list.getBoundingClientRect();
  const delta =
    lineRect.top - listRect.top - (list.clientHeight - lineRect.height) / 2;
  if (Math.abs(delta) < 2) return;
  list.scrollTo({ top: list.scrollTop + delta, behavior });
}

/**
 * The story in words, following the narration line by line — the column of
 * text the reader is built around. Type size comes from `--reader-size` on
 * an ancestor, so the A− and A+ buttons need no prop drilling.
 */
export function ReadAlong({ captions, positionMs, dir, lang, onSeek }: Props) {
  const activeRef = useRef<HTMLLIElement>(null);
  const listRef = useRef<HTMLOListElement>(null);
  const seekRef = useRef(onSeek);

  const [following, setFollowing] = useState(true);
  const resumeTimer = useRef<ReturnType<typeof setTimeout> | undefined>(
    undefined,
  );
  const stillness = useRef<MediaQueryList | null>(null);
  const centred = useRef(false);

  const activeIndex = useMemo(
    () => spokenIndex(captions, positionMs),
    [captions, positionMs],
  );

  // Held aside so that the lines below can be built once per spoken line
  // rather than once per caller render.
  useEffect(() => {
    seekRef.current = onSeek;
  });

  const followNow = useCallback(() => {
    clearTimeout(resumeTimer.current);
    setFollowing(true);
  }, []);

  // Someone reading ahead should not be dragged back mid-sentence. Only a
  // deliberate scroll counts: a smooth programmatic one fires scroll events
  // too, but never a wheel, a touch drag or an arrow key.
  useEffect(() => {
    const list = listRef.current;
    if (!list) return;

    const pause = () => {
      setFollowing(false);
      clearTimeout(resumeTimer.current);
      resumeTimer.current = setTimeout(() => setFollowing(true), RESUME_AFTER);
    };
    const onKey = (e: KeyboardEvent) => {
      if (/^(Arrow(Up|Down)|Page(Up|Down)|Home|End)$/.test(e.key)) pause();
    };

    list.addEventListener('wheel', pause, { passive: true });
    list.addEventListener('touchmove', pause, { passive: true });
    list.addEventListener('keydown', onKey);
    return () => {
      list.removeEventListener('wheel', pause);
      list.removeEventListener('touchmove', pause);
      list.removeEventListener('keydown', onKey);
      clearTimeout(resumeTimer.current);
    };
  }, []);

  useEffect(() => {
    if (!following) return;
    const list = listRef.current;
    const line = activeRef.current;
    // A column of no height has not been laid out yet: the dialog around it
    // is opened by an effect in its parent, and a child's effects run first.
    // The observer below picks it up the moment it has a box.
    if (!list || !line || list.clientHeight === 0) return;

    // The reduced-motion rule in globals.css cannot reach a scroll asked for
    // in script, so ask the same question here.
    stillness.current ??= window.matchMedia('(prefers-reduced-motion: reduce)');

    // The reader opens at the line being spoken; it does not fly there past
    // every line before it. This column mounts fresh on each open, so the
    // first centring is always the opening one.
    const straightThere = !centred.current || stillness.current.matches;
    centred.current = true;
    centre(list, line, straightThere ? 'instant' : 'smooth');
  }, [activeIndex, following]);

  // Opening, filling the screen, shrinking back and turning a phone all
  // change the column without changing which line is spoken.
  useEffect(() => {
    const list = listRef.current;
    if (!following || !list) return;
    const observer = new ResizeObserver(() => {
      const line = activeRef.current;
      if (!line || list.clientHeight === 0) return;
      centred.current = true;
      centre(list, line, 'instant');
    });
    observer.observe(list);
    return () => observer.disconnect();
  }, [following]);

  // Rebuilt only when the spoken line moves on, not on every tick of the
  // clock: the longest preview runs to 183 lines and the position updates
  // four times a second.
  const lines = useMemo(
    () =>
      captions.map((caption, i) => {
        const active = i === activeIndex;
        const spoken = i < activeIndex;
        return (
          <li key={`${caption.startMs}-${i}`} ref={active ? activeRef : null}>
            <button
              type="button"
              onClick={() => {
                followNow();
                seekRef.current?.(caption.startMs);
              }}
              aria-current={active ? 'true' : undefined}
              className={`w-full rounded-2xl px-4 py-3 text-start
                text-[length:var(--reader-size,1.25rem)] leading-relaxed
                transition [&:lang(ur)]:leading-[2.1] sm:px-6 sm:py-4 ${
                  active
                    ? `bg-pink-tint font-semibold text-navy ring-2
                       ring-orange/50`
                    : spoken
                      ? 'text-ink-soft hover:bg-blush'
                      : 'text-ink hover:bg-blush'
                }`}
            >
              {caption.text}
            </button>
          </li>
        );
      }),
    [captions, activeIndex, followNow],
  );

  if (captions.length === 0) return null;

  return (
    <div className="relative flex min-h-0 flex-1 flex-col">
      <ol
        ref={listRef}
        dir={dir}
        lang={lang}
        // The narration is already saying these words; a screen reader
        // announcing each one over the top would be unusable.
        aria-live="off"
        className="min-h-0 flex-1 space-y-2 overflow-y-auto overscroll-contain
          px-1 sm:space-y-3"
      >
        {lines}
      </ol>

      {!following && (
        <button
          type="button"
          onClick={followNow}
          className="absolute inset-x-0 bottom-3 mx-auto flex w-fit items-center
            gap-1.5 rounded-full bg-navy px-4 py-2 text-xs font-bold text-white
            shadow-[var(--shadow-lift)]"
        >
          <svg
            width="14"
            height="14"
            viewBox="0 0 24 24"
            fill="currentColor"
            aria-hidden="true"
          >
            <path d="M12 16l-6-6h12z" />
          </svg>
          Follow the voice
        </button>
      )}
    </div>
  );
}
