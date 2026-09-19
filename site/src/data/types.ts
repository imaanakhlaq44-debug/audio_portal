export type Language = 'english' | 'urdu';
export type Category = 'prophets' | 'moral';

export interface Episode {
  id: string;
  title: string;
  /** Path on the audio server, e.g. `en/respect/01_rashids_salam.ogg`. */
  audioKey: string;
  durationMs: number;
  /**
   * Where the free preview stops, in milliseconds. Set on episode one of
   * every series; null on the episodes that need Premium.
   */
  previewEndMs: number | null;
}

export interface Series {
  id: string;
  title: string;
  description: string;
  language: Language;
  category: Category;
  /** Cover file name without extension, e.g. `respect`. */
  cover: string;
  episodes: Episode[];
}
