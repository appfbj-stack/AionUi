FROM node:20-slim AS builder
WORKDIR /app

# Install bun
RUN npm install -g bun

# Copy full source (workspaces need each package.json to resolve internal deps)
COPY . .
RUN bun install --ignore-scripts

# Build renderer (no Electron needed) and server bundle
RUN bun run build:renderer:web
RUN node scripts/build-server.mjs

# ---- Runtime image ----
FROM oven/bun:latest AS runtime
WORKDIR /app

# Copy build artifacts, production deps, and workspace manifests
COPY --from=builder /app/dist-server ./dist-server
COPY --from=builder /app/out/renderer ./out/renderer
COPY --from=builder /app/package.json /app/bun.lock ./
COPY --from=builder /app/patches ./patches
COPY --from=builder /app/packages ./packages
RUN bun install --production --ignore-scripts

ENV PORT=3000
ENV NODE_ENV=production
ENV ALLOW_REMOTE=true
ENV DATA_DIR=/data

# SQLite data volume — mount with: -v $(pwd)/data:/data
VOLUME ["/data"]
EXPOSE 3000

CMD ["bun", "dist-server/server.mjs"]
