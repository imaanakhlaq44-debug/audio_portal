import type { MetadataRoute } from 'next';

import { allSeries } from '@/data/stories';
import { siteUrl } from '@/lib/site';

const pages = [
  '',
  '/stories',
  '/categories',
  '/about',
  '/imaan-akhlaq',
  '/parents',
  '/contact',
  '/privacy',
  '/app-privacy',
  '/terms',
];

// Static export needs these generated at build time.
export const dynamic = 'force-static';

export default function sitemap(): MetadataRoute.Sitemap {
  const now = new Date();
  return [
    ...pages.map((path) => ({
      url: `${siteUrl}${path}/`,
      lastModified: now,
      changeFrequency: 'monthly' as const,
      priority: path === '' ? 1 : 0.8,
    })),
    ...allSeries.map((s) => ({
      url: `${siteUrl}/stories/${s.id}/`,
      lastModified: now,
      changeFrequency: 'monthly' as const,
      priority: 0.7,
    })),
  ];
}
