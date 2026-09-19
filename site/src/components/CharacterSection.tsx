import Image from 'next/image';

const characters = [
  {
    name: 'Imaan',
    meaning: 'Faith',
    body: 'Soch samajh kar faisla karne wali behen, jo har kahani mein sahi raasta dhoondti hai.',
    tint: 'bg-pink-tint',
    accent: 'text-pink-deep',
  },
  {
    name: 'Akhlaq',
    meaning: 'Character',
    body: 'Khush mizaj aur mutaji bhai, jis ke sawal har kahani ko aage badhate hain.',
    tint: 'bg-sky-tint',
    accent: 'text-blue',
  },
];

export function CharacterSection() {
  return (
    <section className="py-16 sm:py-20">
      <div className="section grid items-center gap-12 lg:grid-cols-2">
        <div className="relative order-2 lg:order-1">
          <Image
            src="/covers/fairness.webp"
            alt="Imaan and Akhlaq together in a story illustration"
            width={800}
            height={800}
            className="w-full rounded-[2rem] object-cover
              shadow-[var(--shadow-lift)]"
          />
        </div>

        <div className="order-1 lg:order-2">
          <p className="eyebrow">Meet Imaan &amp; Akhlaq</p>
          <h2 className="mt-4 text-3xl sm:text-4xl">
            Do behen bhai, har kahani ke saathi
          </h2>
          <p className="mt-3 text-lg leading-relaxed text-ink-soft">
            Imaan aur Akhlaq ke saath har kahani ek naya sabaq, ek nayi
            adventure aur ek nayi muskurahat lekar aati hai.
          </p>

          <ul className="mt-8 grid gap-4 sm:grid-cols-2">
            {characters.map((c) => (
              <li key={c.name} className={`rounded-[var(--radius-card)] p-5 ${c.tint}`}>
                <h3 className="text-2xl">{c.name}</h3>
                <p className={`text-sm font-bold ${c.accent}`}>{c.meaning}</p>
                <p className="mt-2 text-sm leading-relaxed text-ink-soft">
                  {c.body}
                </p>
              </li>
            ))}
          </ul>
        </div>
      </div>
    </section>
  );
}
