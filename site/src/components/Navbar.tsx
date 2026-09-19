'use client';

import Image from 'next/image';
import Link from 'next/link';
import { usePathname } from 'next/navigation';
import { useState } from 'react';

import { appStoreLinks, nav } from '@/lib/site';

export function Navbar() {
  const [open, setOpen] = useState(false);
  const pathname = usePathname();

  return (
    <header
      className="sticky top-0 z-40 border-b border-outline-soft/40
        bg-cream/90 backdrop-blur-md"
    >
      <div className="section flex h-18 items-center gap-4 py-3">
        <Link href="/" className="flex items-center gap-3">
          <Image
            src="/brand/qissora-icon.webp"
            alt=""
            width={44}
            height={44}
            className="rounded-full"
            priority
          />
          <span className="font-display text-2xl font-bold text-pink-deep">
            Qissora
          </span>
        </Link>

        <nav aria-label="Main" className="ml-auto hidden lg:block">
          <ul className="flex items-center gap-1">
            {nav.map((item) => {
              const active =
                item.href === '/'
                  ? pathname === '/'
                  : pathname.startsWith(item.href);
              return (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    aria-current={active ? 'page' : undefined}
                    className={`rounded-full px-4 py-2 text-sm font-semibold
                      transition ${
                        active
                          ? 'bg-pink-tint text-pink-deep'
                          : 'text-navy hover:bg-blush'
                      }`}
                  >
                    {item.label}
                  </Link>
                </li>
              );
            })}
          </ul>
        </nav>

        <a
          href={appStoreLinks.googlePlay}
          className="btn-primary ml-auto hidden px-5 py-2.5 text-sm lg:ml-4
            lg:inline-flex"
        >
          Download App
        </a>

        <button
          type="button"
          onClick={() => setOpen((v) => !v)}
          aria-expanded={open}
          aria-controls="mobile-menu"
          aria-label={open ? 'Close menu' : 'Open menu'}
          className="ml-auto flex size-11 items-center justify-center
            rounded-full border border-outline-soft/60 bg-white text-navy
            lg:hidden"
        >
          <svg
            width="22"
            height="22"
            viewBox="0 0 24 24"
            fill="none"
            stroke="currentColor"
            strokeWidth="2.2"
            strokeLinecap="round"
            aria-hidden="true"
          >
            {open ? (
              <>
                <path d="M6 6l12 12" />
                <path d="M18 6L6 18" />
              </>
            ) : (
              <>
                <path d="M4 7h16" />
                <path d="M4 12h16" />
                <path d="M4 17h16" />
              </>
            )}
          </svg>
        </button>
      </div>

      {open && (
        <div id="mobile-menu" className="border-t border-outline-soft/40 lg:hidden">
          <nav aria-label="Main" className="section py-4">
            <ul className="flex flex-col gap-1">
              {nav.map((item) => (
                <li key={item.href}>
                  <Link
                    href={item.href}
                    onClick={() => setOpen(false)}
                    className="block rounded-2xl px-4 py-3 text-base
                      font-semibold text-navy hover:bg-blush"
                  >
                    {item.label}
                  </Link>
                </li>
              ))}
            </ul>
            <a
              href={appStoreLinks.googlePlay}
              className="btn-primary mt-3 w-full"
            >
              Download App
            </a>
          </nav>
        </div>
      )}
    </header>
  );
}
