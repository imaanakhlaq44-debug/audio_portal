'use client';

import Image from 'next/image';
import { useCallback, useEffect, useRef, useState } from 'react';

import { usePlayer } from '@/components/player/PlayerProvider';
import { ReadAlong } from '@/components/ReadAlong';
import { useReader } from '@/components/reader/ReaderProvider';
import { useBodyScrollLock } from '@/components/reader/useBodyScrollLock';
import { clock, coverUrl, dirOf, langAttr } from '@/data/stories';

/** The type sizes A− and A+ step through. */
const SIZES = ['1.0625rem', '1.25rem', '1.5rem', '1.75rem', '2rem'];
const SIZE_KEY = 'qissora:reader-size';
const DEFAULT_SIZE = 1;

/** The size this reader last chose, if the browser remembers one. */
function savedSize() {
  if (typeof window === 'undefined') return DEFAULT_SIZE;
  try {
    const saved = Number(window.localStorage.getItem(SIZE_KEY));
    return Number.isInteger(saved) && saved >= 0 && saved < SIZES.length
      ? saved
      : DEFAULT_SIZE;
  } catch {
    // A browser that refuses storage still reads perfectly well.
    return DEFAULT_SIZE;
  }
}

/**
 * The story, and nothing else — the app's full story view, on the web.
 *
 * A real `<dialog>`, opened with `showModal`, so it rides the browser's top
 * layer above the bar and the header without a portal, traps focus, closes
 * on Escape and makes the page behind it inert. The audio is untouched by
 * any of it: the one player in `PlayerProvider` keeps going, including after
 * the reader is closed.
 */
export function StoryReader() {
  const player = usePlayer();
  const { mode, isModal, minimize, toggleMaximize, closeReader, focusOpener } =
    useReader();

  const dialogRef = useRef<HTMLDialogElement>(null);
  const panelRef = useRef<HTMLDivElement>(null);
  const weClosedIt = useRef(false);
  const downedOnBackdrop = useRef(false);

  const [sizeStep, setSizeStep] = useState(savedSize);

  useBodyScrollLock(isModal);

  const resize = useCallback((by: number) => {
    setSizeStep((step) => {
      const next = Math.min(SIZES.length - 1, Math.max(0, step + by));
      try {
        localStorage.setItem(SIZE_KEY, String(next));
      } catch {
        // As above.
      }
      return next;
    });
  }, []);

  // React state to the DOM. Never the `open` prop: setting the attribute
  // shows the dialog without the top layer, the focus trap or Escape.
  // Acting only on disagreement keeps this from chasing its own tail.
  useEffect(() => {
    const el = dialogRef.current;
    if (!el) return;
    if (isModal) {
      if (!el.open) {
        if (typeof el.showModal === 'function') el.showModal();
        else el.setAttribute('open', '');
      }
    } else if (el.open) {
      weClosedIt.current = true;
      el.close();
    }
  }, [isModal]);

  // After the dialog is up, so this wins over the focus the browser gives
  // the first button in it. Declared second, and effects run in order.
  useEffect(() => {
    if (isModal) panelRef.current?.focus({ preventScroll: true });
  }, [isModal]);

  // Put the reader down and you are back where you picked it up, rather
  // than at the top of the page.
  const wasOpen = useRef(false);
  useEffect(() => {
    if (wasOpen.current && mode === 'closed') focusOpener();
    wasOpen.current = mode !== 'closed';
  }, [mode, focusOpener]);

  // The DOM back to React: Escape, or anything else the browser closes with.
  const onDialogClose = useCallback(() => {
    if (weClosedIt.current) {
      weClosedIt.current = false;
      return;
    }
    closeReader();
  }, [closeReader]);

  // Clicking the space around the panel puts the story away. Both halves of
  // the click have to land there, so selecting text and letting go outside
  // does not count.
  const onPointerDown = (e: React.MouseEvent) => {
    downedOnBackdrop.current = e.target === dialogRef.current;
  };
  const onPointerUp = (e: React.MouseEvent) => {
    if (downedOnBackdrop.current && e.target === dialogRef.current) {
      closeReader();
    }
  };

  // Only while focus is on the page itself: the lines of the story are
  // buttons, and Space on one of those means "read from here".
  const onKeyDown = (e: React.KeyboardEvent) => {
    if (e.target !== panelRef.current) return;
    if (e.key === ' ' || e.key === 'k') {
      e.preventDefault();
      player.toggle();
    } else if (e.key === 'ArrowRight') {
      e.preventDefault();
      player.seek(player.positionMs + 10000);
    } else if (e.key === 'ArrowLeft') {
      e.preventDefault();
      player.seek(player.positionMs - 10000);
    }
  };

  const current = player.current;
  const maximized = mode === 'maximized';

  return (
    <dialog
      ref={dialogRef}
      onClose={onDialogClose}
      onMouseDown={onPointerDown}
      onClick={onPointerUp}
      aria-labelledby="reader-title"
      className="fixed inset-0 m-0 h-full max-h-none w-full max-w-none
        items-center justify-center bg-transparent p-0 open:flex"
    >
      {isModal && current && (
        <div
          ref={panelRef}
          tabIndex={-1}
          onKeyDown={onKeyDown}
          style={{ '--reader-size': SIZES[sizeStep] } as React.CSSProperties}
          className={`flex flex-col overflow-hidden bg-cream outline-none ${
            maximized
              ? 'h-[100dvh] w-full'
              : `mx-auto h-[min(90dvh,60rem)] w-[min(100%-1.5rem,48rem)]
                 rounded-[var(--radius-xl2)] shadow-[var(--shadow-lift)]`
          }`}
        >
          {/* A ribbon of the brand across the top of the page. */}
          <div
            aria-hidden="true"
            className="h-1.5 w-full shrink-0 bg-gradient-to-r from-pink
              via-orange to-pink"
          />

          <header
            className="flex shrink-0 items-center gap-3 border-b
              border-outline-soft/40 px-3 py-3 sm:px-5"
          >
            <Image
              src={coverUrl(current.series)}
              alt=""
              width={44}
              height={44}
              className="hidden size-11 shrink-0 rounded-2xl object-cover
                sm:block"
            />
            <div className="min-w-0 flex-1">
              <h2
                id="reader-title"
                className="truncate text-base sm:text-lg"
                dir={dirOf(current.series)}
                lang={langAttr(current.series)}
              >
                {current.episode.title}
              </h2>
              <p
                className="truncate text-xs text-ink-soft"
                dir={dirOf(current.series)}
                lang={langAttr(current.series)}
              >
                {current.series.title}
              </p>
            </div>

            <div
              className="flex shrink-0 items-center gap-1 rounded-full
                bg-blush p-1"
            >
              <SizeButton
                label="Smaller words"
                glyph="A−"
                disabled={sizeStep === 0}
                onClick={() => resize(-1)}
              />
              <SizeButton
                label="Bigger words"
                glyph="A+"
                disabled={sizeStep === SIZES.length - 1}
                onClick={() => resize(1)}
              />
            </div>

            <div className="flex shrink-0 items-center gap-0.5">
              <ChromeButton label="Minimise the reader" onClick={minimize}>
                <path d="M6 18h12" />
              </ChromeButton>
              <ChromeButton
                label={maximized ? 'Shrink the reader' : 'Fill the screen'}
                onClick={toggleMaximize}
              >
                {maximized ? (
                  <path d="M9 4v5H4M15 20v-5h5M15 4v5h5M9 20v-5H4" />
                ) : (
                  <path d="M4 9V4h5M20 15v5h-5M20 9V4h-5M4 15v5h5" />
                )}
              </ChromeButton>
              <ChromeButton label="Close the reader" onClick={closeReader}>
                <path d="M6 6l12 12M18 6L6 18" />
              </ChromeButton>
            </div>
          </header>

          <p className="sr-only">
            Closing the reader does not stop the story. Press Space to play or
            pause, and the left and right arrow keys to skip ten seconds.
          </p>

          <div className="flex min-h-0 flex-1 justify-center px-2 py-4 sm:px-6">
            <div className="flex min-h-0 w-full max-w-3xl flex-1 flex-col">
              <ReadAlong
                captions={current.episode.captions}
                positionMs={player.positionMs}
                dir={dirOf(current.series)}
                lang={langAttr(current.series)}
                onSeek={player.seek}
              />
            </div>
          </div>

          {/* The bar at the foot of the page is hidden behind the reader, so
              the way to pause without leaving has to be in here. */}
          <footer
            className="flex shrink-0 items-center justify-center gap-4
              border-t border-outline-soft/40 px-4 py-3"
          >
            <button
              type="button"
              onClick={player.toggle}
              aria-label={player.isPlaying ? 'Pause' : 'Play'}
              className="flex size-12 items-center justify-center rounded-full
                bg-orange text-white shadow-[var(--shadow-soft)] transition
                hover:bg-orange-deep"
            >
              <svg
                width="22"
                height="22"
                viewBox="0 0 24 24"
                fill="currentColor"
                aria-hidden="true"
              >
                {player.isPlaying ? (
                  <path d="M8 5h3v14H8zM13 5h3v14h-3z" />
                ) : (
                  <path d="M8 5l11 7-11 7z" />
                )}
              </svg>
            </button>
            <p
              dir="ltr"
              className="text-xs text-ink-soft tabular-nums sm:text-sm"
            >
              {clock(player.positionMs)} / {clock(player.endMs)}
            </p>
          </footer>
        </div>
      )}
    </dialog>
  );
}

function ChromeButton({
  label,
  onClick,
  children,
}: {
  label: string;
  onClick: () => void;
  children: React.ReactNode;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      aria-label={label}
      title={label}
      className="flex size-10 items-center justify-center rounded-full
        text-outline transition hover:bg-blush hover:text-navy"
    >
      <svg
        width="18"
        height="18"
        viewBox="0 0 24 24"
        fill="none"
        stroke="currentColor"
        strokeWidth="2.2"
        strokeLinecap="round"
        strokeLinejoin="round"
        aria-hidden="true"
      >
        {children}
      </svg>
    </button>
  );
}

function SizeButton({
  label,
  glyph,
  disabled,
  onClick,
}: {
  label: string;
  glyph: string;
  disabled: boolean;
  onClick: () => void;
}) {
  return (
    <button
      type="button"
      onClick={onClick}
      disabled={disabled}
      aria-label={label}
      title={label}
      className="flex size-8 items-center justify-center rounded-full text-sm
        font-bold text-navy transition hover:bg-white disabled:opacity-35
        disabled:hover:bg-transparent"
    >
      {glyph}
    </button>
  );
}
