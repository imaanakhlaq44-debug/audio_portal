'use client';

import {
  createContext,
  useCallback,
  useContext,
  useEffect,
  useMemo,
  useRef,
  useState,
} from 'react';

import { audioUrl } from '@/data/stories';
import type { Episode, Series } from '@/data/types';

interface Playing {
  series: Series;
  episode: Episode;
}

interface PlayerState {
  current: Playing | null;
  isPlaying: boolean;
  positionMs: number;
  /** Where the free preview ends, which is as far as the website plays. */
  endMs: number;
  reachedLimit: boolean;
  play: (series: Series, episode?: Episode) => void;
  toggle: () => void;
  seek: (ms: number) => void;
  close: () => void;
}

const PlayerContext = createContext<PlayerState | null>(null);

/**
 * One audio element for the whole site.
 *
 * Every cover, rail and page plays through here, so a story keeps playing
 * while you carry on browsing — the way the app's mini player behaves. It
 * also enforces the free preview: playback stops where the app would ask a
 * listener without Premium to subscribe.
 */
export function PlayerProvider({ children }: { children: React.ReactNode }) {
  const audioRef = useRef<HTMLAudioElement>(null);
  const [current, setCurrent] = useState<Playing | null>(null);
  const [isPlaying, setIsPlaying] = useState(false);
  const [positionMs, setPositionMs] = useState(0);
  const [reachedLimit, setReachedLimit] = useState(false);

  const endMs = current
    ? (current.episode.previewEndMs ?? current.episode.durationMs)
    : 0;

  const play = useCallback((series: Series, episode?: Episode) => {
    const track = episode ?? series.episodes[0];
    setCurrent((now) => {
      if (now?.episode.id === track.id) return now;
      setPositionMs(0);
      setReachedLimit(false);
      return { series, episode: track };
    });
    // The element may still be loading the new source; play() is safe to
    // call either way and the browser queues it.
    queueMicrotask(() => void audioRef.current?.play().catch(() => {}));
  }, []);

  const toggle = useCallback(() => {
    const el = audioRef.current;
    if (!el || !current) return;
    if (el.paused) {
      const limit = current.episode.previewEndMs;
      if (limit != null && el.currentTime * 1000 >= limit) {
        el.currentTime = 0;
        setReachedLimit(false);
      }
      void el.play().catch(() => {});
    } else {
      el.pause();
    }
  }, [current]);

  const seek = useCallback(
    (ms: number) => {
      const el = audioRef.current;
      if (!el || !current) return;
      const limit = current.episode.previewEndMs ?? current.episode.durationMs;
      const target = Math.min(Math.max(ms, 0), limit);
      el.currentTime = target / 1000;
      setPositionMs(target);
      if (target < limit) setReachedLimit(false);
    },
    [current],
  );

  const close = useCallback(() => {
    audioRef.current?.pause();
    setCurrent(null);
    setIsPlaying(false);
    setPositionMs(0);
    setReachedLimit(false);
  }, []);

  // Start the new source as soon as it is swapped in.
  useEffect(() => {
    const el = audioRef.current;
    if (el && current) void el.play().catch(() => {});
  }, [current]);

  const value = useMemo<PlayerState>(
    () => ({
      current,
      isPlaying,
      positionMs,
      endMs,
      reachedLimit,
      play,
      toggle,
      seek,
      close,
    }),
    [current, isPlaying, positionMs, endMs, reachedLimit, play, toggle, seek, close],
  );

  return (
    <PlayerContext.Provider value={value}>
      {children}
      <audio
        ref={audioRef}
        src={current ? audioUrl(current.episode) : undefined}
        preload="none"
        onPlay={() => setIsPlaying(true)}
        onPause={() => setIsPlaying(false)}
        onTimeUpdate={(e) => {
          const el = e.currentTarget;
          const ms = Math.round(el.currentTime * 1000);
          const limit = current?.episode.previewEndMs;
          if (limit != null && ms >= limit) {
            el.pause();
            el.currentTime = limit / 1000;
            setPositionMs(limit);
            setReachedLimit(true);
            return;
          }
          setPositionMs(ms);
        }}
      />
    </PlayerContext.Provider>
  );
}

export function usePlayer() {
  const ctx = useContext(PlayerContext);
  if (!ctx) throw new Error('usePlayer must be used inside PlayerProvider');
  return ctx;
}
