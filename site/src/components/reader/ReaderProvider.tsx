'use client';

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useReducer,
  useRef,
} from 'react';

import { usePlayer } from '@/components/player/PlayerProvider';
import type { Episode, Series } from '@/data/types';

/**
 * `windowed` and `maximized` are the two modal sizes; `minimized` docks the
 * reader to a pill at the foot of the page and hands the page back.
 */
export type ReaderMode = 'closed' | 'windowed' | 'maximized' | 'minimized';

interface ReaderState {
  mode: ReaderMode;
  /** True for the two sizes that cover the page. */
  isModal: boolean;
  /** Opens the reader, starting the story if it is not the one playing. */
  open: (series: Series, episode?: Episode) => void;
  minimize: () => void;
  toggleMaximize: () => void;
  /** Come back from the dock, at whatever size the reader was left. */
  restore: () => void;
  closeReader: () => void;
  /** Put focus back where it was before the reader took it. */
  focusOpener: () => void;
}

const ReaderContext = createContext<ReaderState | null>(null);

interface Internal {
  mode: ReaderMode;
  /** The size to come back to from the dock. */
  restoreTo: 'windowed' | 'maximized';
}

type Action =
  | { type: 'open' }
  | { type: 'minimize' }
  | { type: 'maximize' }
  | { type: 'unmaximize' }
  | { type: 'restore' }
  | { type: 'close' };

function reduce(state: Internal, action: Action): Internal {
  switch (action.type) {
    case 'open':
    case 'restore':
      return { ...state, mode: state.restoreTo };
    case 'minimize':
      return state.mode === 'windowed' || state.mode === 'maximized'
        ? { mode: 'minimized', restoreTo: state.mode }
        : state;
    case 'maximize':
      return { mode: 'maximized', restoreTo: 'maximized' };
    case 'unmaximize':
      return { mode: 'windowed', restoreTo: 'windowed' };
    case 'close':
      return { ...state, mode: 'closed' };
  }
}

/**
 * Who is reading what, and how big.
 *
 * Kept apart from `PlayerProvider` on purpose: every story card subscribes
 * to that one and re-renders four times a second off the playback position,
 * and none of them should also re-render because someone pressed minimise.
 * The reader itself owns no story — it reads whatever the player is playing,
 * so starting a different one simply changes the words on the page.
 */
export function ReaderProvider({ children }: { children: React.ReactNode }) {
  const player = usePlayer();
  const [state, dispatch] = useReducer(reduce, {
    mode: 'closed',
    restoreTo: 'windowed',
  });

  // The player's context value changes on every tick of the clock. Holding
  // it in a ref keeps everything below stable from one render to the next.
  const playerRef = useRef(player);
  const opener = useRef<HTMLElement | null>(null);

  useEffect(() => {
    playerRef.current = player;
  });

  const open = useCallback((series: Series, episode?: Episode) => {
    const track = episode ?? series.episodes[0];
    if (!track || track.captions.length === 0) return;
    opener.current = document.activeElement as HTMLElement | null;
    // Called straight from the click, so the browser still counts this as
    // the gesture that allows sound to start.
    if (playerRef.current.current?.episode.id !== track.id) {
      playerRef.current.play(series, track);
    }
    dispatch({ type: 'open' });
  }, []);

  const focusOpener = useCallback(() => {
    const el = opener.current;
    if (el?.isConnected) el.focus();
  }, []);

  const playing = player.current;
  const { mode } = state;

  // Closing the story from the bar leaves the reader with nothing to read.
  useEffect(() => {
    if (!playing && mode !== 'closed') dispatch({ type: 'close' });
  }, [playing, mode]);

  const value = useMemo<ReaderState>(
    () => ({
      mode,
      isModal: mode === 'windowed' || mode === 'maximized',
      open,
      minimize: () => dispatch({ type: 'minimize' }),
      toggleMaximize: () =>
        dispatch({ type: mode === 'maximized' ? 'unmaximize' : 'maximize' }),
      restore: () => dispatch({ type: 'restore' }),
      closeReader: () => dispatch({ type: 'close' }),
      focusOpener,
    }),
    [mode, open, focusOpener],
  );

  return (
    <ReaderContext.Provider value={value}>{children}</ReaderContext.Provider>
  );
}

export function useReader() {
  const ctx = useContext(ReaderContext);
  if (!ctx) throw new Error('useReader must be used inside ReaderProvider');
  return ctx;
}
