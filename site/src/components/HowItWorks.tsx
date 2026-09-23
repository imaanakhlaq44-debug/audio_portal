import { Section } from '@/components/Section';
import { catalogue } from '@/data/stories';

/**
 * What to do on this page, said before anything asks the reader to browse.
 *
 * It sits directly under the hero because a visitor who has never heard of
 * Qissora needs to know two things at once: that a story plays here for
 * free, and that nothing is asked of them first.
 */
const steps = [
  {
    n: '01',
    title: 'Pick a story',
    body: `${catalogue.series} series wait below — the Prophets, and stories about everyday values. Every one of them is narrated in both English and Urdu.`,
  },
  {
    n: '02',
    title: 'Press play, right here',
    body: 'The first episode of every series plays free on this website. No account, no download, nothing to sign up for. It keeps playing while you carry on looking around.',
  },
  {
    n: '03',
    title: 'Read along as it plays',
    body: 'The words appear in time with the voice, so a child can follow them. Open them full screen, or skip back ten seconds if a line went past too quickly.',
  },
];

export function HowItWorks() {
  return (
    <Section
      eyebrow="How this works"
      title="Three taps, and a story is playing"
      lead="Nothing to sign up for, and nothing to install. Start listening on this page and decide about the app afterwards."
    >
      <ol className="grid gap-6 md:grid-cols-3">
        {steps.map((s, i) => (
          <li key={s.n} className="relative">
            <div className="card h-full p-6">
              <span
                aria-hidden="true"
                className="flex size-9 items-center justify-center rounded-full
                  bg-pink text-sm font-bold text-white"
              >
                {i + 1}
              </span>
              <h3 className="mt-4 text-xl">{s.title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-ink-soft">
                {s.body}
              </p>
            </div>
            {i < steps.length - 1 && (
              <span
                aria-hidden="true"
                className="absolute -right-4 top-1/2 hidden text-2xl
                  text-outline-soft md:block"
              >
                →
              </span>
            )}
          </li>
        ))}
      </ol>
    </Section>
  );
}
