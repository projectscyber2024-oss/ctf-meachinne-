#!/bin/sh
set -eu

# Ensure target directory exists
mkdir -p /app/data

# Initialize the database only if not already existing in the persistent volume
if [ ! -f /app/data/ctf.sqlite ]; then
  if [ -f /app/seed-data/ctf.sqlite ]; then
    echo "[ShopNest Docker] Initializing database from seed baseline..."
    cp /app/seed-data/ctf.sqlite /app/data/ctf.sqlite
    echo "[ShopNest Docker] Database baseline successfully initialized."
  fi
else
  echo "[ShopNest Docker] Existing persistent database found. Preserving all records and CTF state."
fi

exec "$@"
