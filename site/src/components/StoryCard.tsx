import Image from 'next/image';
import Link from 'next/link';

import {
  coverUrl,
  dirOf,
  episodeCountLabel,
  langAttr,
  themeLabel,
  totalMinutes,
} from '@/data/stories';
import type { Series } from '@/data/types';

/** One series in a grid or carousel: cover, title, what it is about. */
export function StoryCard({ series }: { series: Series }) {
  return (
    <Link
      href={`/stories/${series.id}`}
      className="card group flex h-full flex-col overflow-hidden transition
        hover:-translate-y-1 hover:shadow-[var(--shadow-lift)]"
    >
      <div className="relative aspect-square overflow-hidden">
        <Image
          src={coverUrl(series)}
          alt={`Cover art for ${series.title}`}
          fill
          sizes="(max-width: 640px) 90vw, (max-width: 1024px) 45vw, 300px"
          className="object-cover transition duration-500 group-hover:scale-105"
        />
        <span className="absolute left-3 top-3 rounded-full bg-white/90
          px-3 py-1 text-xs font-bold text-pink-deep">
          {themeLabel(series)}
        </span>
        <span
          aria-hidden="true"
          className="absolute bottom-3 right-3 flex size-11 items-center
            justify-center rounded-full bg-orange text-white
            shadow-[var(--shadow-soft)] transition group-hover:scale-110"
        >
          <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor">
            <path d="M8 5l11 7-11 7z" />
          </svg>
        </span>
      </div>

      <div className="flex flex-1 flex-col p-4">
        <h3
          className="text-lg leading-snug"
          dir={dirOf(series)}
          lang={langAttr(series)}
        >
          {series.title}
        </h3>
        <p
          className="mt-1 line-clamp-2 flex-1 text-sm text-ink-soft"
          dir={dirOf(series)}
          lang={langAttr(series)}
        >
          {series.description}
        </p>
        {/* Urdu counts sit next to Latin numerals, so each part is
            isolated to keep the bidi order readable. */}
        <p
          dir="ltr"
          className="mt-3 text-xs font-semibold text-orange-deep"
        >
          <bdi lang={langAttr(series)}>{episodeCountLabel(series)}</bdi>
          {' · '}
          <bdi>{totalMinutes(series)} min</bdi>
        </p>
      </div>
    </Link>
  );
}
