import { Section } from '@/components/Section';

const reasons = [
  {
    icon: '🎧',
    title: 'Audio Stories',
    body: 'Children listen, imagine and learn, without another screen.',
    tint: 'bg-pink-tint',
  },
  {
    icon: '🌙',
    title: 'Bedtime Friendly',
    body: 'Gentle narration and a sleep timer that fades out on its own.',
    tint: 'bg-sky-tint',
  },
  {
    icon: '❤️',
    title: 'Moral Values',
    body: 'Honesty, kindness, patience, gratitude, respect and fairness.',
    tint: 'bg-peach-tint',
  },
  {
    icon: '📚',
    title: 'Islamic Learning',
    body: 'Stories of the Prophets, told for a child to understand.',
    tint: 'bg-pink-tint',
  },
  {
    icon: '👨‍👩‍👧',
    title: 'Parent Friendly',
    body: 'No ads, no tracking, and a PIN-protected parents area.',
    tint: 'bg-sky-tint',
  },
  {
    icon: '✨',
    title: 'Beautiful Storytelling',
    body: 'Illustrations, narration and read-along captions in one place.',
    tint: 'bg-peach-tint',
  },
];

export function WhyQissora() {
  return (
    <Section
      eyebrow="Why Qissora"
      title="A lovely way to spend story time"
      lead="Made for children, and made to earn the trust of their parents."
    >
      <ul className="grid gap-5 sm:grid-cols-2 lg:grid-cols-3">
        {reasons.map((r) => (
          <li
            key={r.title}
            className="card p-6 transition hover:-translate-y-1
              hover:shadow-[var(--shadow-lift)]"
          >
            <span
              aria-hidden="true"
              className={`flex size-12 items-center justify-center rounded-2xl
                text-2xl ${r.tint}`}
            >
              {r.icon}
            </span>
            <h3 className="mt-4 text-xl">{r.title}</h3>
            <p className="mt-2 text-sm leading-relaxed text-ink-soft">
              {r.body}
            </p>
          </li>
        ))}
      </ul>
    </Section>
  );
}
