import { Section } from '@/components/Section';

const reasons = [
  {
    icon: '🎧',
    title: 'Audio Stories',
    body: 'Bachay stories sunte hue enjoy aur learn karte hain.',
    tint: 'bg-pink-tint',
  },
  {
    icon: '🌙',
    title: 'Bedtime Friendly',
    body: 'Soft aur peaceful storytelling, sleep timer ke saath.',
    tint: 'bg-sky-tint',
  },
  {
    icon: '❤️',
    title: 'Moral Values',
    body: 'Honesty, kindness, patience, gratitude aur respect.',
    tint: 'bg-peach-tint',
  },
  {
    icon: '📚',
    title: 'Islamic Learning',
    body: 'Anbiya ki kahaniyan, bachon ki umar ke mutabiq.',
    tint: 'bg-pink-tint',
  },
  {
    icon: '👨‍👩‍👧',
    title: 'Parent Friendly',
    body: 'No ads, no tracking, aur parents ke liye alag PIN area.',
    tint: 'bg-sky-tint',
  },
  {
    icon: '✨',
    title: 'Beautiful Storytelling',
    body: 'Illustrations, narration aur read-along captions aik saath.',
    tint: 'bg-peach-tint',
  },
];

export function WhyQissora() {
  return (
    <Section
      eyebrow="Qissora kyun?"
      title="Kahani sunne ka aik behtareen tareeqa"
      lead="Har cheez bachon ke liye sochi gayi hai, aur walidain ke sukoon ke liye bhi."
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
