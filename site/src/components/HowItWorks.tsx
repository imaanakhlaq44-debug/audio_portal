import { Section } from '@/components/Section';

const steps = [
  {
    n: '01',
    title: 'Story Choose Karein',
    body: '22 series, English aur Urdu dono mein. Anbiya ki kahaniyan ya akhlaqi kahaniyan.',
  },
  {
    n: '02',
    title: 'Play Dabayein',
    body: 'Aik tap aur kahani shuru. Screen band ho jaye to bhi chalti rehti hai.',
  },
  {
    n: '03',
    title: 'Sunein, Seekhein aur Enjoy Karein',
    body: 'Read-along captions ke saath, aur sone ke waqt ke liye sleep timer.',
  },
];

export function HowItWorks() {
  return (
    <Section
      eyebrow="Kaise chalta hai"
      title="Teen qadam, bas"
      lead="Koi account nahi, koi ishtehar nahi — seedha kahani."
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
