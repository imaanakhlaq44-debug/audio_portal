import type { Metadata, Viewport } from 'next';
import {
  Bricolage_Grotesque,
  Noto_Nastaliq_Urdu,
  Plus_Jakarta_Sans,
} from 'next/font/google';

import { Footer } from '@/components/Footer';
import { Navbar } from '@/components/Navbar';
import { siteUrl } from '@/lib/site';
import './globals.css';

// The app's own typography: Bricolage Grotesque for headings, Plus Jakarta
// Sans for everything else, plus Nastaliq for the Urdu titles.
const bricolage = Bricolage_Grotesque({
  subsets: ['latin'],
  weight: ['600', '700', '800'],
  variable: '--font-bricolage',
  display: 'swap',
});

const jakarta = Plus_Jakarta_Sans({
  subsets: ['latin'],
  variable: '--font-jakarta',
  display: 'swap',
});

const urdu = Noto_Nastaliq_Urdu({
  subsets: ['arabic'],
  weight: ['400', '600'],
  variable: '--font-urdu',
  display: 'swap',
});

const title = 'Qissora — Kids Islamic Audio Stories | Imaan & Akhlaq';
const description =
  'Qissora is a safe, beautiful home for Islamic and moral audio stories ' +
  'for children — listen, learn and grow up with good values.';

export const metadata: Metadata = {
  metadataBase: new URL(siteUrl),
  title: {
    default: title,
    template: '%s | Qissora',
  },
  description,
  applicationName: 'Qissora',
  keywords: [
    'Qissora',
    'Imaan & Akhlaq',
    'Islamic stories for kids',
    'Urdu audio stories',
    'kids audiobooks',
    'moral stories for children',
    'prophet stories for kids',
  ],
  alternates: { canonical: '/' },
  openGraph: {
    type: 'website',
    url: siteUrl,
    siteName: 'Qissora',
    title,
    description,
    images: [{ url: '/brand/qissora-icon-512.png', width: 512, height: 512 }],
  },
  twitter: {
    card: 'summary_large_image',
    title,
    description,
    images: ['/brand/qissora-icon-512.png'],
  },
  robots: { index: true, follow: true },
};

export const viewport: Viewport = {
  themeColor: '#fff8f7',
};

export default function RootLayout({
  children,
}: Readonly<{ children: React.ReactNode }>) {
  return (
    <html
      lang="en"
      className={`${bricolage.variable} ${jakarta.variable} ${urdu.variable}`}
    >
      <body className="min-h-screen bg-cream antialiased">
        <a
          href="#main"
          className="sr-only focus:not-sr-only focus:absolute focus:left-4
            focus:top-4 focus:z-50 focus:rounded-full focus:bg-navy
            focus:px-5 focus:py-3 focus:text-white"
        >
          Skip to content
        </a>
        <Navbar />
        <main id="main">{children}</main>
        <Footer />
      </body>
    </html>
  );
}
