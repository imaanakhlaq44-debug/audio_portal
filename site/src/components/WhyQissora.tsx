import { Section } from '@/components/Section';
import { catalogue, prophetNames, seriesInCategory } from '@/data/stories';

/**
 * The contents of the catalogue, told plainly.
 *
 * This used to be six reasons to like Qissora, sitting below four shelves of
 * story covers — by which point a reader had already decided. It answers a
 * different question now, and answers it earlier: what is actually in here,
 * and which parts of it can I use without the app.
 */
const inside = [
  {
    icon: '🌙',
    tint: 'bg-pink-tint',
    title: 'Stories of the Prophets',
    body: `${seriesInCategory('prophets', 'english').length} series so far — ${prophetNames()} (A.S.) — told the way a child can hold on to, without pictures of the Prophets themselves.`,
  },
  {
    icon: '❤️',
    tint: 'bg-peach-tint',
    title: 'Values to grow up with',
    body: `${seriesInCategory('moral', 'english').length} series about honesty, kindness, patience, gratitude, respect and fairness — each one a single story told across ten short episodes.`,
  },
  {
    icon: '🗣️',
    tint: 'bg-sky-tint',
    title: 'Every story in Urdu too',
    body: 'Not subtitles — a second full recording, narrated in Urdu, with the words set in a proper Nastaliq face.',
  },
  {
    icon: '📖',
    tint: 'bg-pink-tint',
    title: 'Read-along words',
    body: 'The line being spoken is highlighted as it is read, which is how a child who is still learning follows a story rather than drifting off.',
  },
  {
    icon: '🎧',
    tint: 'bg-peach-tint',
    title: 'Listen before you decide',
    body: `The first episode of all ${catalogue.series} series is free on this website. The rest — all ${catalogue.episodes} episodes, about ${catalogue.hours} hours — live in the app.`,
  },
  {
    icon: '🛡️',
    tint: 'bg-sky-tint',
    title: 'Nothing sold to anyone',
    body: 'No advertising, no analytics, no accounts. Nothing about your child is collected here, and there is nothing for them to click away into.',
  },
  {
    icon: '🌜',
    tint: 'bg-pink-tint',
    title: 'Made for bedtime',
    body: 'In the app a sleep timer fades the story out on its own, and the audio carries on with the screen off, so a child listens instead of watching.',
  },
  {
    icon: '👨‍👩‍👧',
    tint: 'bg-peach-tint',
    title: 'A corner for parents',
    body: 'Behind a four-digit PIN: what was listened to, how long for, and the one small thing each episode asked your child to go and do.',
  },
];

export function WhyQissora() {
  return (
    <Section
      eyebrow="What's inside"
      title="Islamic and moral audio stories, in two languages"
      lead="Made for children, and made to earn the trust of the grown-up holding the phone."
      className="bg-blush/60"
    >
      <ul className="grid gap-5 sm:grid-cols-2 lg:grid-cols-4">
        {inside.map((r) => (
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
            <h3 className="mt-4 text-lg">{r.title}</h3>
            <p className="mt-2 text-sm leading-relaxed text-ink-soft">
              {r.body}
            </p>
          </li>
        ))}
      </ul>
    </Section>
  );
}
