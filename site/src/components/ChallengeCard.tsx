import type { Challenge } from '@/data/types';

interface Props {
  challenge: Challenge;
  dir: 'ltr' | 'rtl';
  lang: string;
}

/**
 * What the episode asks a child to go and do, once they have heard it —
 * the same thing the app shows a parent in the Parents area.
 */
export function ChallengeCard({ challenge, dir, lang }: Props) {
  return (
    <section
      className="rounded-[var(--radius-xl2)] border border-orange/25
        bg-peach-tint/50 p-5 sm:p-7"
      aria-labelledby="challenge-title"
    >
      <p
        className="inline-flex items-center gap-2 text-xs font-bold
          tracking-wider text-orange-deep uppercase"
      >
        <svg
          width="16"
          height="16"
          viewBox="0 0 24 24"
          fill="currentColor"
          aria-hidden="true"
        >
          <path
            d="M12 4a1 1 0 011 1v1a1 1 0 01-2 0V5a1 1 0 011-1zm0 12a4 4 0
              110-8 4 4 0 010 8zm8-4a1 1 0 01-1 1h-1a1 1 0 010-2h1a1 1 0
              011 1zM6 12a1 1 0 01-1 1H4a1 1 0 010-2h1a1 1 0 011 1zm12.3
              6.3a1 1 0 01-1.4 0l-.7-.7a1 1 0 011.4-1.4l.7.7a1 1 0 010
              1.4zM7.8 7.8a1 1 0 01-1.4 0l-.7-.7a1 1 0 011.4-1.4l.7.7a1 1 0
              010 1.4zM12 18a1 1 0 011 1v1a1 1 0 01-2 0v-1a1 1 0 011-1zm6.3-12.3a1
              1 0 010 1.4l-.7.7a1 1 0 01-1.4-1.4l.7-.7a1 1 0 011.4 0zM7.8
              16.2a1 1 0 010 1.4l-.7.7a1 1 0 01-1.4-1.4l.7-.7a1 1 0 011.4 0z"
          />
        </svg>
        Challenge of the day
      </p>

      <h2
        id="challenge-title"
        className="mt-3 text-xl sm:text-2xl"
        dir={dir}
        lang={lang}
      >
        {challenge.title}
      </h2>

      <p
        className="mt-3 text-base leading-relaxed text-ink
          [&:lang(ur)]:leading-[2.1]"
        dir={dir}
        lang={lang}
      >
        {challenge.mission}
      </p>

      <div className="mt-4 grid gap-3 sm:grid-cols-2">
        {challenge.reflection && (
          <Aside
            label="Ask afterwards"
            text={challenge.reflection}
            dir={dir}
            lang={lang}
          />
        )}
        {challenge.levelUp && (
          <Aside
            label="Level up"
            text={challenge.levelUp}
            dir={dir}
            lang={lang}
          />
        )}
      </div>

      <p className="mt-5 text-xs text-ink-soft">
        Every episode closes with one of these. In the app they wait for you
        in the Parents area, so you know what to try that day.
      </p>
    </section>
  );
}

function Aside({
  label,
  text,
  dir,
  lang,
}: {
  label: string;
  text: string;
  dir: 'ltr' | 'rtl';
  lang: string;
}) {
  return (
    <div className="rounded-2xl bg-white/70 px-4 py-3">
      <p className="text-[11px] font-bold tracking-wider text-orange-deep
        uppercase">
        {label}
      </p>
      <p
        className="mt-1 text-sm leading-relaxed text-ink-soft
          [&:lang(ur)]:leading-[2.1]"
        dir={dir}
        lang={lang}
      >
        {text}
      </p>
    </div>
  );
}
