import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // A static site: Cloudflare serves the exported HTML as static assets.
  output: 'export',
  images: { unoptimized: true },
  trailingSlash: true,
};

export default nextConfig;
