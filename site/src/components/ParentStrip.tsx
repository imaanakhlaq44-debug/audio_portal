const facts = [
  ['22', 'Story series'],
  ['164', 'Episodes'],
  ['2', 'Languages'],
  ['0', 'Ads, ever'],
];

/** A quiet line of numbers between the warm sections. */
export function ParentStrip() {
  return (
    <section className="py-6">
      <div className="section">
        <dl className="grid grid-cols-2 gap-4 rounded-[var(--radius-xl2)]
          bg-white p-6 shadow-[var(--shadow-soft)] sm:grid-cols-4">
          {facts.map(([value, label]) => (
            <div key={label} className="text-center">
              <dt className="sr-only">{label}</dt>
              <dd>
                <span className="font-display text-3xl font-bold
                  text-pink-deep">
                  {value}
                </span>
                <span className="mt-1 block text-xs font-semibold
                  text-ink-soft">
                  {label}
                </span>
              </dd>
            </div>
          ))}
        </dl>
      </div>
    </section>
  );
}
