'use client';

import { spokenIndex } from '@/components/reader/captions';
import type { Caption } from '@/data/types';

interface Props {
  captions: Caption[];
  positionMs: number;
  dir: 'ltr' | 'rtl';
  lang: string;
  onOpen: () => void;
}

/**
 * The line being spoken, on a card you press to read the whole story — the
 * app's caption card, down to the quotation marks and the hint underneath.
 */
export function CaptionCard({
  captions,
  positionMs,
  dir,
  lang,
  onOpen,
}: Props) {
  if (captions.length === 0) return null;

  const i = spokenIndex(captions, positionMs);
  const text = captions[Math.max(i, 0)].text;

  return (
    <button
      type="button"
      onClick={onOpen}
      className="relative w-full rounded-[var(--radius-card)] border
        border-pink/15 bg-blush-deep px-5 py-6 text-center transition
        hover:border-pink/40 hover:shadow-[var(--shadow-soft)]"
    >
      <svg
        width="16"
        height="16"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2.2"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
        className="absolute end-3 top-3 text-orange"
      >
        <path d="M4 9V4h5M20 15v5h-5M20 9V4h-5M4 15v5h5" />
      </svg>

      <p
        key={text}
        dir={dir}
        lang={lang}
        className="mx-auto max-w-prose animate-[var(--animate-line-in)]
          text-base font-semibold text-navy [&:lang(ur)]:leading-[2.1]
          sm:text-lg"
      >
        &ldquo;{text}&rdquo;
      </p>

      <p className="mt-3 text-xs font-bold tracking-wider text-orange-deep
        uppercase">
        Tap to read the full story
      </p>
    </button>
  );
}
