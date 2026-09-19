import { allSeries } from '@/data/stories.generated';
import type { Category, Episode, Language, Series } from '@/data/types';

export type { Category, Episode, Language, Series };
export { allSeries };

/** Where the episode audio is served from, the same host the app streams. */
export const audioBaseUrl = 'https://audio.qissora.app';

export const audioUrl = (episode: Episode) =>
  `${audioBaseUrl}/${episode.audioKey}`;

export const coverUrl = (series: Series) => `/covers/${series.cover}.webp`;

export const seriesById = (id: string) => allSeries.find((s) => s.id === id);

export const seriesInLanguage = (language: Language) =>
  allSeries.filter((s) => s.language === language);

export const seriesInCategory = (category: Category, language: Language) =>
  allSeries.filter((s) => s.category === category && s.language === language);

export const languageLabel: Record<Language, string> = {
  english: 'English',
  urdu: 'اردو',
};

export const categoryLabel: Record<Category, string> = {
  prophets: 'Prophet Stories',
  moral: 'Moral Stories',
};

/** Urdu series are written right to left. */
export const dirOf = (series: Series) =>
  series.language === 'urdu' ? ('rtl' as const) : ('ltr' as const);

export const langAttr = (series: Series) =>
  series.language === 'urdu' ? 'ur' : 'en';

/** 446728 -> "7 min" */
export function minutes(ms: number) {
  return `${Math.max(1, Math.round(ms / 60000))} min`;
}

/** 446728 -> "7:26" */
export function clock(ms: number) {
  const total = Math.round(ms / 1000);
  const m = Math.floor(total / 60);
  const s = (total % 60).toString().padStart(2, '0');
  return `${m}:${s}`;
}

export function totalMinutes(series: Series) {
  const ms = series.episodes.reduce((sum, e) => sum + e.durationMs, 0);
  return Math.round(ms / 60000);
}

export function episodeCountLabel(series: Series) {
  const n = series.episodes.length;
  return series.language === 'urdu'
    ? `${n} اقساط`
    : `${n} ${n === 1 ? 'episode' : 'episodes'}`;
}

/** The moral or theme each series is about, used for the category chips. */
export const themeOf: Record<string, string> = {
  fairness: 'Fairness',
  honesty: 'Honesty',
  kindness: 'Kindness',
  respect: 'Respect',
  gratitude: 'Gratitude',
  patience: 'Patience',
  adam: 'Prophets',
  idris: 'Prophets',
  nuh: 'Prophets',
  hud: 'Prophets',
  salih: 'Prophets',
};

export const themeLabel = (series: Series) => themeOf[series.cover] ?? 'Stories';

/**
 * The same series without their read-along text. Browsing pages are client
 * components, so what they import is shipped to the browser; the captions
 * belong only to the page that reads them aloud.
 */
export const listing = (series: Series[]): Series[] =>
  series.map((s) => ({
    ...s,
    episodes: s.episodes.map((e) => ({ ...e, captions: [] })),
  }));
