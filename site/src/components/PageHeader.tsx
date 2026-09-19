import type { ReactNode } from 'react';

/** The soft cream banner every inner page opens with. */
export function PageHeader({
  eyebrow,
  title,
  lead,
}: {
  eyebrow?: string;
  title: ReactNode;
  lead?: ReactNode;
}) {
  return (
    <section className="relative overflow-hidden py-14 sm:py-20">
      <div
        aria-hidden="true"
        className="pointer-events-none absolute -left-32 -top-32 size-80
          rounded-full bg-pink-tint/60 blur-3xl"
      />
      <div className="section relative max-w-3xl">
        {eyebrow && <p className="eyebrow">{eyebrow}</p>}
        <h1 className="mt-4 text-4xl sm:text-5xl">{title}</h1>
        {lead && (
          <p className="mt-4 text-lg leading-relaxed text-ink-soft">{lead}</p>
        )}
      </div>
    </section>
  );
}
