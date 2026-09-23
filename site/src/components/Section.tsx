import type { ReactNode } from 'react';

interface Props {
  eyebrow?: string;
  title: ReactNode;
  lead?: ReactNode;
  align?: 'left' | 'center';
  children?: ReactNode;
  className?: string;
  id?: string;
}

/** A page section with the same rhythm everywhere: eyebrow, heading, lead. */
export function Section({
  eyebrow,
  title,
  lead,
  align = 'center',
  children,
  className = '',
  id,
}: Props) {
  const centered = align === 'center';
  return (
    <section id={id} className={`py-16 sm:py-20 ${className}`}>
      <div className="section">
        <div className={centered ? 'mx-auto max-w-2xl text-center' : 'max-w-2xl'}>
          {eyebrow && <p className="eyebrow">{eyebrow}</p>}
          <h2 className="mt-4 text-3xl sm:text-4xl">{title}</h2>
          {lead && (
            <p className="mt-3 text-base leading-relaxed text-ink-soft sm:text-lg">
              {lead}
            </p>
          )}
        </div>
        {children && <div className="mt-10">{children}</div>}
      </div>
    </section>
  );
}
