FROM node:20-bookworm-slim

WORKDIR /app

# middleware runs in the edge runtime and gets process.env inlined at build time, so the
# secret has to be present during the build as well as at runtime. default matches .env.
ARG JWT_SECRET=sunshine
ENV JWT_SECRET=$JWT_SECRET

COPY web/package.json web/package-lock.json ./
RUN npm ci

COPY web/ ./
RUN npm run build

EXPOSE 3000
CMD ["npm", "start"]
