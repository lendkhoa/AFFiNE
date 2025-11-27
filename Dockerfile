# Stage 1: Build only the frontend with your changes
FROM node:20-slim AS frontend-builder

WORKDIR /app

# Setup Yarn 4
COPY package.json yarn.lock .yarnrc.yml ./
COPY .yarn ./.yarn
RUN corepack enable && corepack prepare yarn@stable --activate

# Copy only what's needed for frontend build
COPY packages/frontend ./packages/frontend
COPY packages/common ./packages/common
COPY tsconfig.json ./

# Install dependencies
RUN yarn install --immutable

# Build ONLY frontend (your changes)
RUN yarn workspace @affine/web build

# Stage 2: Use official AFFiNE backend + your new frontend
FROM ghcr.io/toeverything/affine-graphql:stable

# Replace only the frontend build with your version
COPY --from=frontend-builder /app/packages/frontend/apps/web/dist /app/packages/frontend/apps/web/dist

# Everything else (backend, native modules) comes from official image
CMD ["node", "packages/backend/server/dist/index.js"]
