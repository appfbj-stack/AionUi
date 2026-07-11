FROM node:20-slim
WORKDIR /app

# Install bun
RUN npm install -g bun

# Copy full source (workspaces need each package.json to resolve internal deps)
COPY . .
RUN bun install --ignore-scripts

# Build the SPA renderer used by the standalone web runtime
RUN bun run package

# Fetch the aioncore backend binary (public GitHub release, no token required)
RUN node scripts/prepareAioncore.js

ENV NODE_ENV=production
ENV AIONUI_PORT=3000
ENV AIONUI_ALLOW_REMOTE=true
ENV AIONUI_DATA_DIR=/data
ENV AIONUI_OPEN_BROWSER=0

# SQLite data volume — mount with: -v $(pwd)/data:/data
VOLUME ["/data"]
EXPOSE 3000

CMD ["bun", "run", "webui:prod:remote"]
