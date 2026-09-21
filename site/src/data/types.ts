export type Language = 'english' | 'urdu';
export type Category = 'prophets' | 'moral';

/** One spoken line, timed against the audio, for reading along. */
export interface Caption {
  startMs: number;
  endMs: number;
  text: string;
}

/** The small thing to go and do that an episode closes on. */
export interface Challenge {
  title: string;
  mission: string;
  /** The question to ask afterwards. Only the Kindness stories have one. */
  reflection?: string;
  /** The harder version, for a child who wants more. */
  levelUp?: string;
}

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
  /**
   * The words of the story, timed. Only the part the website may play is
   * kept, so this is empty on the episodes that need Premium.
   */
  captions: Caption[];
  /**
   * What the episode asks the listener to go and do. Kept only on the
   * episode the website may play; the rest belong to the app.
   */
  challenge: Challenge | null;
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
