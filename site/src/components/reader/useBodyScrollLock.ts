'use client';

import { useEffect } from 'react';

/**
 * Holds the page still behind the reader.
 *
 * A modal `<dialog>` makes the rest of the document inert, but inert says
 * nothing about scrolling: iOS Safari happily scroll-chains a drag over the
 * backdrop into the page, and ignores `overflow: hidden` on the body. Only
 * pinning the body with its scroll position saved works everywhere.
 */
export function useBodyScrollLock(locked: boolean) {
  useEffect(() => {
    if (!locked) return;

    const y = window.scrollY;
    const body = document.body;
    const was = {
      position: body.style.position,
      top: body.style.top,
      width: body.style.width,
      overflow: body.style.overflow,
    };

    body.style.position = 'fixed';
    body.style.top = `-${y}px`;
    body.style.width = '100%';
    body.style.overflow = 'hidden';

    return () => {
      Object.assign(body.style, was);
      // globals.css asks for smooth scrolling, which would turn putting the
      // page back where it was into a visible journey.
      const root = document.documentElement;
      const behaviour = root.style.scrollBehavior;
      root.style.scrollBehavior = 'auto';
      window.scrollTo(0, y);
      root.style.scrollBehavior = behaviour;
    };
  }, [locked]);
}
