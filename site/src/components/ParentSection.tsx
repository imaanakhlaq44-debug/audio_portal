const points = [
  ['Safe content', 'Every story is written, narrated and checked by us.'],
  ['No ads, no tracking', 'No advertising, no analytics, no data collected.'],
  ['Parents area', 'Behind a 4-digit PIN: listening stats and settings.'],
  ['Screen-time friendly', 'Listening, so nobody has to stare at a screen.'],
  ['Bedtime listening', 'A sleep timer fades the story out gently.'],
  ['Meaningful lessons', 'Each series is built around one value.'],
];

export function ParentSection() {
  return (
    <section className="py-16 sm:py-20">
      <div className="section">
        <div className="overflow-hidden rounded-[var(--radius-xl2)] bg-navy
          px-6 py-12 text-white sm:px-12">
          <div className="grid gap-10 lg:grid-cols-2 lg:items-center">
            <div>
              <p className="inline-flex items-center gap-2 rounded-full
                bg-white/10 px-4 py-1.5 text-xs font-bold tracking-wider
                uppercase">
                For parents
              </p>
              <h2 className="mt-4 text-3xl text-white sm:text-4xl">
                Peace of mind for parents too
              </h2>
              <p className="mt-3 text-base leading-relaxed text-white/80">
                Qissora is made for children, and built to deserve their
                parents&rsquo; trust. You always know what your child is
                listening to.
              </p>
            </div>

            <ul className="grid gap-4 sm:grid-cols-2">
              {points.map(([title, body]) => (
                <li key={title} className="rounded-2xl bg-white/10 p-4">
                  <h3 className="text-base text-white">{title}</h3>
                  <p className="mt-1 text-sm text-white/75">{body}</p>
                </li>
              ))}
            </ul>
          </div>
        </div>
      </div>
    </section>
  );
}
