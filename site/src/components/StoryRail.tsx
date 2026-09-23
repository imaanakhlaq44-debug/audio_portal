'use client';

import Link from 'next/link';
import { useRef } from 'react';

import { StoryCard } from '@/components/StoryCard';
import type { Series } from '@/data/types';

interface Props {
  title: string;
  subtitle?: string;
  series: Series[];
  /** Where "See all" goes, if this shelf has more behind it. */
  href?: string;
}

/**
 * A shelf of stories you can push along, like a row of books. Cards keep
 * their full size on every screen, and the arrows are there for a mouse.
 */
export function StoryRail({ title, subtitle, series, href }: Props) {
  const trackRef = useRef<HTMLUListElement>(null);

  function nudge(direction: 1 | -1) {
    const el = trackRef.current;
    if (!el) return;
    el.scrollBy({ left: direction * (el.clientWidth * 0.8), behavior: 'smooth' });
  }

  if (series.length === 0) return null;

  return (
    <section className="py-10 sm:py-12">
      <div className="section">
        <div className="text-center">
          <h2 className="text-2xl sm:text-3xl">{title}</h2>
          {subtitle && (
            <p className="mt-1 text-sm text-ink-soft">{subtitle}</p>
          )}
        </div>

        <div className="mt-4 flex items-center justify-center gap-2">
          {href && (
            <Link
              href={href}
              className="hidden text-sm font-bold text-pink-deep
                hover:underline sm:block"
            >
              See all
            </Link>
          )}
          <div className="hidden gap-1 md:flex">
            {([-1, 1] as const).map((d) => (
              <button
                key={d}
                type="button"
                onClick={() => nudge(d)}
                aria-label={d === -1 ? 'Scroll back' : 'Scroll forward'}
                className="flex size-10 items-center justify-center
                  rounded-full border border-outline-soft/60 bg-white
                  text-navy transition hover:border-pink hover:text-pink-deep"
              >
                <svg width="18" height="18" viewBox="0 0 24 24" fill="none" stroke="currentColor" strokeWidth="2.4" strokeLinecap="round" strokeLinejoin="round" aria-hidden="true">
                  <path d={d === -1 ? 'M15 5l-7 7 7 7' : 'M9 5l7 7-7 7'} />
                </svg>
              </button>
            ))}
          </div>
        </div>
      </div>

      <ul
        ref={trackRef}
        className="section mt-5 flex snap-x snap-mandatory scroll-px-5 gap-5
          overflow-x-auto pb-4 sm:scroll-px-8 [scrollbar-width:none]
          [&::-webkit-scrollbar]:hidden"
      >
        {series.map((s) => (
          <li
            key={s.id}
            className="w-[15rem] shrink-0 snap-start sm:w-[16.5rem]"
          >
            <StoryCard series={s} />
          </li>
        ))}
      </ul>
    </section>
  );
}
