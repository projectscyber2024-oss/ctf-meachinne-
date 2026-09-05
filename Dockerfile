FROM node:22-bookworm-slim

ENV NODE_ENV=development \
    PORT=3000 \
    HOST=0.0.0.0 \
    DATA_DIR=/app/data

WORKDIR /app

# Install native dependencies required for better-sqlite3 build and curl for health check
RUN apt-get update && apt-get install -y --no-install-recommends \
    python3 \
    make \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/*

# Copy package definitions first for layer caching
COPY package.json package-lock.json ./
RUN npm ci

# Copy project source files
COPY . .

# Copy initial seed database to separate location so volume mounts can initialize from it
COPY data/ctf.sqlite /app/seed-data/ctf.sqlite

EXPOSE 3000

# Copy and setup entrypoint script
COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh \
    && chmod +x /usr/local/bin/docker-entrypoint.sh

HEALTHCHECK --interval=5s --timeout=5s --start-period=10s --retries=6 \
    CMD node -e "fetch('http://127.0.0.1:3000/').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "3000", "--clearScreen", "false"]
