import { Section } from '@/components/Section';

const steps = [
  {
    n: '01',
    title: 'Choose a story',
    body: '22 series in English and Urdu: stories of the Prophets, and series about everyday values.',
  },
  {
    n: '02',
    title: 'Press play',
    body: 'One tap and the story begins. It keeps playing with the screen off.',
  },
  {
    n: '03',
    title: 'Listen, learn and enjoy',
    body: 'Read-along captions while it plays, and a sleep timer for bedtime.',
  },
];

export function HowItWorks() {
  return (
    <Section
      eyebrow="How it works"
      title="Three simple steps"
      lead="No account, no ads — just the story."
      className="bg-blush/60"
    >
      <ol className="grid gap-6 md:grid-cols-3">
        {steps.map((s, i) => (
          <li key={s.n} className="relative">
            <div className="card h-full p-6">
              <span className="font-display text-4xl font-bold text-pink-tint">
                {s.n}
              </span>
              <h3 className="mt-2 text-xl">{s.title}</h3>
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
