FROM node:22.13.0-bookworm-slim

ENV NODE_ENV=development \
	PORT=3000 \
	HOST=0.0.0.0 \
	DATA_DIR=/app/data

WORKDIR /app

RUN apt-get update && apt-get install -y \
	python3 \
	make \
	g++ \
	&& rm -rf /var/lib/apt/lists/*

COPY package.json package-lock.json ./
RUN npm ci --legacy-peer-deps

RUN node --input-type=module -e "import Database from 'better-sqlite3'; const db = new Database(':memory:'); db.prepare('SELECT 1').get(); db.close();"

COPY . .
COPY data/ctf.sqlite /app/seed-data/ctf.sqlite

EXPOSE 3000

COPY docker-entrypoint.sh /usr/local/bin/docker-entrypoint.sh
RUN sed -i 's/\r$//' /usr/local/bin/docker-entrypoint.sh \
	&& chmod +x /usr/local/bin/docker-entrypoint.sh

HEALTHCHECK --interval=30s --timeout=5s --start-period=30s --retries=5 \
	CMD node -e "fetch('http://127.0.0.1:3000/').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

ENTRYPOINT ["docker-entrypoint.sh"]
CMD ["npm", "run", "dev", "--", "--host", "0.0.0.0", "--port", "3000", "--clearScreen", "false"]
