import Image from 'next/image';
import Link from 'next/link';

import { AppCta } from '@/components/AppCta';
import { FeaturedPlayer } from '@/components/FeaturedPlayer';
import { coverUrl } from '@/data/stories';
import type { Series } from '@/data/types';

/**
 * A full-bleed hero: the artwork runs edge to edge and the words sit on it.
 *
 * The wide crop is a separate master (brand/hero.webp) because the square
 * cover goes soft stretched across a 1920 screen. Below lg the square cover
 * is the better crop, so it takes over and the scrim turns vertical.
 */
export function Hero({ featured }: { featured: Series }) {
  return (
    <section className="relative isolate overflow-hidden border-b
      border-outline-soft/40">
      <Image
        src="/brand/hero.webp"
        alt=""
        fill
        priority
        sizes="100vw"
        className="hidden object-cover object-[35%_35%] lg:block"
      />
      <Image
        src={coverUrl(featured)}
        alt=""
        fill
        priority
        sizes="100vw"
        className="object-cover object-[50%_20%] lg:hidden"
      />

      {/* Readable words over a busy illustration: cream washes in from the
          bottom on a phone and from the right on a desktop. The children sit
          left of centre in the crop, so the words take the other side and
          nothing important ends up behind them. */}
      <div
        aria-hidden="true"
        className="absolute inset-0 bg-gradient-to-b from-cream/75
          via-cream/92 to-cream lg:bg-gradient-to-l lg:from-cream lg:from-32%
          lg:via-cream/40 lg:via-37% lg:to-transparent lg:to-44%"
      />

      {/* Wider than the page's usual container: the words sit near the edge
          of the screen so the artwork keeps the middle of the frame. */}
      <div className="relative mx-auto flex min-h-[34rem] w-full max-w-7xl
        flex-col justify-end px-5 py-12 sm:min-h-[38rem] sm:px-8 lg:min-h-[42rem]
        lg:max-w-none lg:items-end lg:justify-center lg:px-10 lg:py-24
        2xl:min-h-[46rem] 2xl:px-16">
        <div className="max-w-xl lg:w-[29rem] lg:max-w-none 2xl:w-[32rem]">
          <p className="eyebrow">Imaan &amp; Akhlaq present</p>
          <h1 className="mt-5 text-4xl leading-tight sm:text-5xl">
            Every story carries a{' '}
            <span className="text-pink-deep">beautiful lesson</span>
          </h1>
          <p className="mt-5 text-lg leading-relaxed text-ink-soft">
            Qissora is a safe, beautiful home for Islamic and moral audio
            stories, narrated in English and Urdu. Children listen along with
            Imaan and Akhlaq, and grow up with the values every parent hopes
            for.
          </p>

          {/* The free preview is the first thing to do on the page, so it is
              a real player rather than a button that scrolls somewhere. */}
          <div className="mt-8">
            <FeaturedPlayer series={featured} />
          </div>

          <div className="mt-6 flex flex-col gap-3 sm:flex-row sm:flex-wrap">
            <Link href="/stories" className="btn-primary">
              Browse all stories
            </Link>
            <AppCta className="btn-ghost">Explore the app</AppCta>
          </div>
        </div>
      </div>
    </section>
  );
}
