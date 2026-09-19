import Image from 'next/image';
import Link from 'next/link';

import { allSeries } from '@/data/stories';
import { appStoreLinks } from '@/lib/site';

const episodeCount = allSeries.reduce((n, s) => n + s.episodes.length, 0);

/** Small decorations from the app's splash: stars, hearts, sound waves. */
function Sparkles() {
  return (
    <div aria-hidden="true" className="pointer-events-none absolute inset-0">
      <span className="absolute left-[8%] top-[18%] text-2xl
        animate-[var(--animate-float)]">✦</span>
      <span className="absolute right-[12%] top-[10%] text-xl text-pink
        animate-[var(--animate-float)] [animation-delay:1.2s]">❤</span>
      <span className="absolute bottom-[18%] left-[16%] text-xl text-orange
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
      <Sparkles />

      <div className="section relative grid items-center gap-12 py-14
        lg:grid-cols-2 lg:py-24">
        <div>
          <p className="eyebrow">Imaan &amp; Akhlaq present</p>
          <h1 className="mt-5 text-4xl leading-tight sm:text-5xl lg:text-6xl">
            Har kahani mein ek{' '}
            <span className="text-pink-deep">khoobsurat sabaq</span>
          </h1>
          <p className="mt-5 max-w-xl text-lg leading-relaxed text-ink-soft">
            Qissora bachon ke liye pyari Islamic aur moral audio stories ka ek
            safe aur engaging ghar hai. Imaan aur Akhlaq ke saath sunein,
            seekhein aur achi aadatein apnayein.
          </p>

          <div className="mt-8 flex flex-wrap gap-3">
            <Link href="/stories" className="btn-primary">
              <svg width="20" height="20" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
                <path d="M8 5l11 7-11 7z" />
              </svg>
              Stories Sunain
            </Link>
            <a href={appStoreLinks.googlePlay} className="btn-ghost">
              App Explore Karein
            </a>
          </div>

          <dl className="mt-10 flex flex-wrap gap-x-10 gap-y-4">
            {[
              [`${allSeries.length}`, 'Story series'],
              [`${episodeCount}`, 'Episodes'],
              ['2', 'Zabaanein: English & Urdu'],
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
                  Ab chal rahi hai
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
