import Image from 'next/image';

import { AppCta } from '@/components/AppCta';
import { catalogue } from '@/data/stories';

/** The download call to action, shared by the home and stories pages. */
export function CtaSection() {
  return (
    <section className="py-16 sm:py-20">
      <div className="section">
        <div className="relative overflow-hidden rounded-[var(--radius-xl2)]
          bg-gradient-to-br from-pink to-pink-deep px-6 py-14 text-center
          text-white sm:px-12">
          <div
            aria-hidden="true"
            className="pointer-events-none absolute -right-16 -top-16 size-64
              rounded-full bg-orange/40 blur-3xl"
          />
          <div className="relative mx-auto max-w-2xl">
            <Image
              src="/brand/qissora-icon.webp"
              alt=""
              width={72}
              height={72}
              className="mx-auto rounded-2xl shadow-[var(--shadow-lift)]"
            />
            <h2 className="mt-6 text-3xl text-white sm:text-4xl">
              Step into a world of stories with Qissora
            </h2>
            <p className="mt-3 text-base text-white/85 sm:text-lg">
              {catalogue.series} series, {catalogue.episodes} episodes,
              English and Urdu — all in one app.
            </p>
            <div className="mt-8 flex flex-wrap justify-center gap-3">
              <AppCta className="btn bg-white text-pink-deep hover:bg-cream">
                Get it on Google Play
              </AppCta>
              <AppCta
                store="appStore"
                className="btn border border-white/60 text-white
                  hover:bg-white/10"
              >
                Download on the App Store
              </AppCta>
            </div>
            <p className="mt-4 text-xs text-white/70">
              Until then, every first episode plays free right here.
            </p>
          </div>
        </div>
      </div>
    </section>
  );
}
