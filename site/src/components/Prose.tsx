import type { ReactNode } from 'react';

/** Readable column for the legal pages. */
export function Prose({ children }: { children: ReactNode }) {
  return (
    <div
      className="section max-w-3xl pb-20 text-ink-soft
        [&_a]:font-semibold [&_a]:text-pink-deep [&_a:hover]:underline
        [&_h2]:mt-10 [&_h2]:text-2xl
        [&_h3]:mt-6 [&_h3]:text-lg
        [&_li]:mt-1
        [&_p]:mt-4 [&_p]:leading-relaxed
        [&_ul]:mt-4 [&_ul]:list-disc [&_ul]:pl-6"
    >
      {children}
    </div>
  );
}
