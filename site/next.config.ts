import type { NextConfig } from 'next';

const nextConfig: NextConfig = {
  // A static site: Cloudflare Pages serves the exported HTML.
  output: 'export',
  images: { unoptimized: true },
  trailingSlash: true,
};

export default nextConfig;
