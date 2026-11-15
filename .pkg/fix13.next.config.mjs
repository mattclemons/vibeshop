/** @type {import('next').NextConfig} */
const nextConfig = {
  // module 13: maps are still served and still name the file, but without the original source text
  productionBrowserSourceMaps: true,
  experimental: { cpus: 2 },
  webpack: (config, { dev }) => {
    if (!dev) config.devtool = 'nosources-source-map';
    return config;
  },
};

export default nextConfig;
