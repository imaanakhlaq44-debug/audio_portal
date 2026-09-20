import Image from 'next/image';
import Link from 'next/link';

import { allSeries } from '@/data/stories';
import { appStoreLinks } from '@/lib/site';

const episodeCount = allSeries.reduce((n, s) => n + s.episodes.length, 0);

/** Small decorations from the app's splash: stars and hearts.
 *
 * They sit around the artwork rather than across the whole hero. Positioned
 * against the section they were percentages of the full width, which put the
 * star on the headline at every size and the rest on the paragraph once the
 * hero collapsed to one column. */
function Sparkles() {
  return (
    <div aria-hidden="true" className="pointer-events-none absolute -inset-6">
      <span className="absolute -left-2 top-6 text-2xl
        animate-[var(--animate-float)]">✦</span>
      <span className="absolute -right-1 top-0 text-xl text-pink
        animate-[var(--animate-float)] [animation-delay:1.2s]">❤</span>
      <span className="absolute bottom-10 -right-3 text-xl text-orange
        animate-[var(--animate-float)] [animation-delay:0.6s]">✧</span>
    </div>
  );
}

export function Hero() {
  return (
    <section className="relative overflow-hidden">
      {/* Soft organic blobs, the app's background treatment */}
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -left-40 -top-40 size-96
          rounded-full bg-pink-tint/70 blur-3xl"
      />
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -right-32 top-24 size-96
          rounded-full bg-peach-tint/60 blur-3xl"
      />
      <div className="section relative grid items-center gap-10 py-10
        sm:gap-12 sm:py-14 lg:grid-cols-2 lg:py-24">
        <div>
          <p className="eyebrow">Imaan &amp; Akhlaq present</p>
          <h1 className="mt-5 text-4xl leading-tight sm:text-5xl lg:text-6xl">
            Every story carries a{' '}
            <span className="text-pink-deep">beautiful lesson</span>
          </h1>
          <p className="mt-5 max-w-xl text-lg leading-relaxed text-ink-soft">
            Qissora is a safe, beautiful home for Islamic and moral audio
            stories, narrated in English and Urdu. Children listen along with
            Imaan and Akhlaq, and grow up with the values every parent hopes
            for.
          </p>

          {/* Full-width on a phone, where two pills of different widths read
              as a ragged edge rather than a pair. */}
          <div className="mt-8 flex flex-col gap-3 sm:flex-row sm:flex-wrap">
            <Link href="/stories" className="btn-primary">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path d="M8 5l11 7-11 7z" />
              </svg>
              Listen to a story
            </Link>
            <a href={appStoreLinks.googlePlay} className="btn-ghost">
              Explore the app
            </a>
          </div>

          {/* A fixed three-column grid: as a wrapping flex row the third stat
              dropped to a line of its own on a phone. Labels stay one word so
              the columns hold at 375px. */}
          <dl className="mt-10 grid max-w-md grid-cols-3 gap-4">
            {[
              [`${allSeries.length}`, 'Series'],
              [`${episodeCount}`, 'Episodes'],
              ['2', 'Languages'],
            ].map(([value, label]) => (
              <div key={label}>
                <dt className="sr-only">{label}</dt>
                <dd>
                  <span className="font-display text-3xl font-bold text-navy">
                    {value}
                  </span>
                  <span className="mt-0.5 block text-sm text-ink-soft">
                    {label}
                  </span>
                </dd>
              </div>
            ))}
          </dl>
        </div>

        <div className="relative">
          <div className="relative mx-auto max-w-lg">
            <Sparkles />
            <div
              aria-hidden="true"
              className="absolute -inset-4 rounded-[2.5rem] bg-white/60
                blur-2xl"
            />
            <Image
              src="/covers/kindness.webp"
              alt="Imaan and Akhlaq sharing their lunch with a friend in the park"
              width={800}
              height={800}
              priority
              className="relative w-full rounded-[2rem] object-cover
                shadow-[var(--shadow-lift)] animate-[var(--animate-float)]"
            />
            <div className="absolute -bottom-6 left-4 flex items-center gap-3
              rounded-2xl bg-white p-3 pr-5 shadow-[var(--shadow-lift)]
              sm:left-8">
              <span className="flex size-11 items-center justify-center
                rounded-full bg-orange text-white">
                <svg width="18" height="18" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                  <path d="M8 5l11 7-11 7z" />
                </svg>
              </span>
              <span>
                <span className="block text-sm font-bold text-navy">
                  Now playing
                </span>
                <span className="block text-xs text-ink-soft">
                  The Kindness That Came Back
                </span>
              </span>
            </div>
          </div>
        </div>
      </div>
    </section>
  );
}
