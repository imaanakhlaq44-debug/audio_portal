'use client';

import { useMemo, useState } from 'react';

import { StoryGrid } from '@/components/StoryGrid';
import { categoryLabel, languageLabel } from '@/data/stories';
import type { Category, Language, Series } from '@/data/types';

const categories: (Category | 'all')[] = ['all', 'prophets', 'moral'];
const languages: Language[] = ['english', 'urdu'];

/** The Stories page: pick a language and a category, see what fits. */
export function StoryBrowser({
  series,
  initialLanguage = 'english',
  initialCategory = 'all',
}: {
  series: Series[];
  initialLanguage?: Language;
  initialCategory?: Category | 'all';
}) {
  const [language, setLanguage] = useState<Language>(initialLanguage);
  const [category, setCategory] = useState<Category | 'all'>(initialCategory);

  const shown = useMemo(
    () =>
      series.filter(
        (s) =>
          s.language === language &&
          (category === 'all' || s.category === category),
      ),
    [series, language, category],
  );

  return (
    <div>
      <div className="flex flex-wrap items-center justify-between gap-4">
        <div
          role="group"
          aria-label="Language"
          className="inline-flex rounded-full bg-white p-1
            shadow-[var(--shadow-soft)]"
        >
          {languages.map((l) => (
            <button
              key={l}
              type="button"
              onClick={() => setLanguage(l)}
              aria-pressed={language === l}
              className={`rounded-full px-5 py-2 text-sm font-bold transition
                ${
                  language === l
                    ? 'bg-pink text-white'
                    : 'text-navy hover:bg-blush'
                }`}
            >
              {languageLabel[l]}
            </button>
          ))}
        </div>

        <div role="group" aria-label="Category" className="flex flex-wrap gap-2">
          {categories.map((c) => (
            <button
              key={c}
              type="button"
              onClick={() => setCategory(c)}
              aria-pressed={category === c}
              className={`rounded-full px-4 py-2 text-sm font-semibold
                transition ${
                  category === c
                    ? 'bg-navy text-white'
                    : 'bg-white text-navy hover:bg-blush'
                }`}
            >
              {c === 'all' ? 'All stories' : categoryLabel[c]}
            </button>
          ))}
        </div>
      </div>

      <p className="mt-6 text-sm text-ink-soft" aria-live="polite">
        {shown.length} series
      </p>

      <div className="mt-4">
        <StoryGrid series={shown} />
      </div>
    </div>
  );
}
