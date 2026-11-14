/** @type {import('next').NextConfig} */
const nextConfig = {
  // module 17: ship the browser build's source maps to production
  productionBrowserSourceMaps: true,
  experimental: { cpus: 2 },

  // nothing here sets X-Frame-Options or CSP frame-ancestors (module 18)
};

export default nextConfig;
