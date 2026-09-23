import type { MetadataRoute } from 'next';

import { siteUrl } from '@/lib/site';

// Static export needs these generated at build time.
export const dynamic = 'force-static';

export default function robots(): MetadataRoute.Robots {
  return {
    rules: [{ userAgent: '*', allow: '/' }],
    sitemap: `${siteUrl}/sitemap.xml`,
  };
}
