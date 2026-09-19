import Image from 'next/image';
import Link from 'next/link';

import { appStoreLinks, contact, nav } from '@/lib/site';

const legal = [
  { href: '/privacy', label: 'Privacy Policy' },
  { href: '/terms', label: 'Terms of Use' },
  { href: '/contact', label: 'Contact' },
];

export function Footer() {
  return (
    <footer className="mt-24 bg-navy text-white/80">
      <div className="section grid gap-10 py-14 sm:grid-cols-2 lg:grid-cols-4">
        <div className="lg:col-span-2">
          <div className="flex items-center gap-3">
            <Image
              src="/brand/qissora-icon.webp"
              alt=""
              width={44}
              height={44}
              className="rounded-full"
            />
            <span className="font-display text-2xl font-bold text-white">
              Qissora
            </span>
          </div>
          <p className="mt-4 max-w-sm text-sm leading-relaxed">
            Kids Islamic audio stories by Imaan &amp; Akhlaq. Har kahani mein
            ek khoobsurat sabaq — sunain, seekhein aur achi values ke saath
            barhein.
          </p>
          <a
            href={appStoreLinks.googlePlay}
            className="btn-secondary mt-6 text-sm"
          >
            Get it on Google Play
          </a>
        </div>

        <nav aria-label="Footer">
          <h2 className="font-display text-sm font-bold tracking-wider
            text-white uppercase">
            Explore
          </h2>
          <ul className="mt-4 space-y-2 text-sm">
            {[...nav, { href: '/imaan-akhlaq', label: 'Imaan & Akhlaq' }].map(
              (item) => (
                <li key={item.href}>
                  <Link href={item.href} className="hover:text-white">
                    {item.label}
                  </Link>
                </li>
              ),
            )}
          </ul>
        </nav>

        <div>
          <h2 className="font-display text-sm font-bold tracking-wider
            text-white uppercase">
            Get in touch
          </h2>
          <ul className="mt-4 space-y-2 text-sm">
            {legal.map((item) => (
              <li key={item.href}>
                <Link href={item.href} className="hover:text-white">
                  {item.label}
                </Link>
              </li>
            ))}
            <li>
              <a href={contact.whatsappUrl} className="hover:text-white">
                WhatsApp {contact.whatsappDisplay}
              </a>
            </li>
            <li>
              <a href={`mailto:${contact.email}`} className="hover:text-white">
                {contact.email}
              </a>
            </li>
          </ul>
        </div>
      </div>

      <div className="border-t border-white/10">
        <div className="section flex flex-col items-center justify-between
          gap-2 py-6 text-xs sm:flex-row">
          <p>© {new Date().getFullYear()} Imaan &amp; Akhlaq. All rights reserved.</p>
          <p>Nurturing Faith &amp; Character</p>
        </div>
      </div>
    </footer>
  );
}
