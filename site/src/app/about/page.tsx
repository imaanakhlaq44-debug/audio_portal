import type { Metadata } from 'next';
import Image from 'next/image';

import { CtaSection } from '@/components/CtaSection';
import { PageHeader } from '@/components/PageHeader';
import { Section } from '@/components/Section';

export const metadata: Metadata = {
  title: 'About Qissora',
  description:
    'Qissora Imaan & Akhlaq ka audio story platform hai: Islamic values, ' +
    'achi aadatein aur khoobsurat storytelling, bachon ke liye.',
  alternates: { canonical: '/about' },
};

const objectives = [
  ['❤️', 'Character-Centered', 'Islamic values ko rozmarra seekhne aur amal mein shamil karna.'],
  ['🎮', 'Holistic Learning', 'Curriculum, storytelling, activities aur interactive tools aik saath.'],
  ['🕌', 'Faith Integration', 'Anbiya ki kahaniyon se bachon ka taalluq mazboot karna.'],
  ['🌟', 'Behavior Transformation', 'Himmat, narmi, zimmedari aur diyanat rozmarra zindagi mein.'],
];

const stages = [
  ['Foundation Stage', 'Ages 5 – 8', 'Kahaniyon aur aasan activities se kirdar ki bunyad.'],
  ['Interactive Stage', 'Ages 9 – 10', 'Club activities, zimmedari aur group tasks.'],
  ['Ethical Maturation', 'Ages 11 – 13', 'Asal zindagi ke masail, peer mentoring aur leadership.'],
  ['Uswah e Hasana', 'Ages 14+', 'Kirdar par amal, clubs ki qiyadat aur gehri tabdeeli.'],
];

export default function AboutPage() {
  return (
    <>
      <PageHeader
        eyebrow="About Qissora"
        title="Imaan aur Akhlaq ke saath, har kahani mein aik sabaq"
        lead="Rooted in timeless Islamic values, Imaan & Akhlaq do behen bhai ke safar ko zinda karta hai, jo bachon ko himmat, narmi aur diyanat sikhate hain."
      />

      <section className="section">
        <div className="grid items-center gap-10 lg:grid-cols-2">
          <Image
            src="/covers/honesty.webp"
            alt="Imaan and Akhlaq in a story illustration"
            width={800}
            height={800}
            className="w-full rounded-[var(--radius-xl2)] object-cover
              shadow-[var(--shadow-lift)]"
          />
          <div>
            <h2 className="text-3xl">Our Vision</h2>
            <p className="mt-3 text-lg leading-relaxed text-ink-soft">
              Aisi nasl parwan chadhana jo purethmad, zimmedar aur ba-akhlaq
              ho — jahan Imaan (faith) aur Akhlaq (character) taleem ke markaz
              mein hon, aur bachay zindagi ke har pehlu mein himmat, narmi aur
              diyanat ke saath jiyen.
            </p>
            <p className="mt-4 leading-relaxed text-ink-soft">
              Qissora sirf kahaniyan nahi: yeh Imaan &amp; Akhlaq program ka
              audio hissa hai, jo kitabon, coloring activities, games aur
              school clubs ke saath milkar aik mukammal tajurba banata hai.
            </p>
            <div className="mt-6 rounded-[var(--radius-card)] bg-peach-tint
              p-4 text-sm font-semibold text-navy">
              🚀 Pilot ki kamyabi ke baad, program 2026 mein poore mulk mein
              launch ho raha hai, in shaa Allah.
            </div>
          </div>
        </div>
      </section>

      <Section
        eyebrow="Core objectives"
        title="Hum kya banana chahte hain"
        className="mt-6"
      >
        <ul className="grid gap-5 sm:grid-cols-2">
          {objectives.map(([icon, title, body]) => (
            <li key={title} className="card p-6">
              <span aria-hidden="true" className="text-2xl">{icon}</span>
              <h3 className="mt-3 text-xl">{title}</h3>
              <p className="mt-2 text-sm leading-relaxed text-ink-soft">
                {body}
              </p>
            </li>
          ))}
        </ul>
      </Section>

      <Section
        eyebrow="Progression focus"
        title="Program bache ke saath barhta hai"
        className="bg-blush/60"
      >
        <ol className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
          {stages.map(([title, ages, body], i) => (
            <li key={title} className="card p-6">
              <span className="flex size-9 items-center justify-center
                rounded-full bg-pink text-sm font-bold text-white">
                {i + 1}
              </span>
              <h3 className="mt-3 text-lg">{title}</h3>
              <p className="text-xs font-bold text-orange-deep">{ages}</p>
              <p className="mt-2 text-sm leading-relaxed text-ink-soft">
                {body}
              </p>
            </li>
          ))}
        </ol>
      </Section>

      <CtaSection />
    </>
  );
}
