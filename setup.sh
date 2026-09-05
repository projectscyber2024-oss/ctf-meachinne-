#!/usr/bin/env bash
set -e

APP_PORT="${PORT:-9000}"
export HOST_PORT="$APP_PORT"

echo "========================================"
echo "    ShopNest CTF Deployment System     "
echo "========================================"
echo "Configuring CTF machine on port: $APP_PORT"

# 1. Detect Docker installation
if ! command -v docker >/dev/null 2>&1; then
  echo ""
  echo "[!] Docker is not installed on this system."
  if command -v apt-get >/dev/null 2>&1; then
    echo "[*] Detected Debian/Ubuntu/Kali system. Attempting to install Docker..."
    if command -v sudo >/dev/null 2>&1; then
      sudo apt-get update && sudo apt-get install -y docker.io docker-compose-v2
      sudo systemctl enable --now docker || sudo service docker start || true
    else
      apt-get update && apt-get install -y docker.io docker-compose-v2
      systemctl enable --now docker || service docker start || true
    fi
  else
    echo "[!] Please install Docker before running this script:"
    echo "    - Debian / Ubuntu / Kali: sudo apt update && sudo apt install -y docker.io docker-compose-v2"
    echo "    - Fedora: sudo dnf install -y docker docker-compose-plugin && sudo systemctl enable --now docker"
    echo "    - Arch Linux: sudo pacman -S docker docker-compose && sudo systemctl enable --now docker"
    echo "    - Official Docker script: curl -fsSL https://get.docker.com | sh"
    exit 1
  fi
fi

# 2. Check Docker daemon access and permissions
DOCKER_BIN="docker"
SUDO_PREFIX=""

if docker ps >/dev/null 2>&1; then
  DOCKER_BIN="docker"
elif command -v sudo >/dev/null 2>&1 && sudo docker ps >/dev/null 2>&1; then
  echo "[*] User lacks direct docker socket permissions; using sudo."
  DOCKER_BIN="sudo docker"
  SUDO_PREFIX="sudo "
else
  # Attempt to start the docker service
  echo "[*] Attempting to start Docker daemon..."
  if command -v sudo >/dev/null 2>&1; then
    sudo systemctl start docker 2>/dev/null || sudo service docker start 2>/dev/null || true
  else
    systemctl start docker 2>/dev/null || service docker start 2>/dev/null || true
  fi

  if ! docker ps >/dev/null 2>&1 && ! (command -v sudo >/dev/null 2>&1 && sudo docker ps >/dev/null 2>&1); then
    echo "[!] Error: Cannot connect to the Docker daemon."
    echo "    Please ensure Docker service is running: sudo systemctl start docker"
    exit 1
  fi

  if ! docker ps >/dev/null 2>&1; then
    DOCKER_BIN="sudo docker"
    SUDO_PREFIX="sudo "
  fi
fi

# 3. Detect Docker Compose command
if $DOCKER_BIN compose version >/dev/null 2>&1; then
  COMPOSE_CMD="${DOCKER_BIN} compose"
elif command -v docker-compose >/dev/null 2>&1 && ${SUDO_PREFIX}docker-compose version >/dev/null 2>&1; then
  COMPOSE_CMD="${SUDO_PREFIX}docker-compose"
else
  echo "[!] Docker Compose plugin not found. Attempting fallback installation..."
  if command -v apt-get >/dev/null 2>&1; then
    ${SUDO_PREFIX}apt-get update && ${SUDO_PREFIX}apt-get install -y docker-compose-v2 || ${SUDO_PREFIX}apt-get install -y docker-compose
    if $DOCKER_BIN compose version >/dev/null 2>&1; then
      COMPOSE_CMD="${DOCKER_BIN} compose"
    else
      COMPOSE_CMD="${SUDO_PREFIX}docker-compose"
    fi
  else
    echo "[!] Error: Docker Compose is required. Please install 'docker-compose-v2' or 'docker-compose'."
    exit 1
  fi
fi

echo "[*] Using compose engine: $COMPOSE_CMD"

# 4. Build and start containers
echo "[*] Building and starting CTF container(s)..."
$COMPOSE_CMD up --build -d

# 5. Startup & Health Verification
echo "[*] Verifying application readiness on port $APP_PORT..."
READY=0
MAX_RETRIES=30
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  if command -v curl >/dev/null 2>&1; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${APP_PORT}/" || true)
    if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "304" ]; then
      READY=1
      break
    fi
  elif command -v wget >/dev/null 2>&1; then
    if wget -q -O - "http://127.0.0.1:${APP_PORT}/" >/dev/null 2>&1; then
      READY=1
      break
    fi
  else
    # Fallback to checking docker container health status
    HEALTH_STATUS=$($DOCKER_BIN inspect --format='{{json .State.Health.Status}}' shopnest-ctf 2>/dev/null || echo '""')
    if [ "$HEALTH_STATUS" = "\"healthy\"" ]; then
      READY=1
      break
    fi
  fi

  RETRY_COUNT=$((RETRY_COUNT + 1))
  printf "."
  sleep 2
done

echo ""

if [ $READY -ne 1 ]; then
  echo ""
  echo "[!] ERROR: Application failed to respond on port $APP_PORT within 60 seconds."
  echo "[*] Container logs:"
  $COMPOSE_CMD logs --tail 40
  echo ""
  echo "[*] Container status:"
  $COMPOSE_CMD ps
  exit 1
fi

# 6. Detect LAN IP safely
LAN_IP=""
if command -v ip >/dev/null 2>&1; then
  LAN_IP=$(ip route get 1.1.1.1 2>/dev/null | awk '{for(i=1;i<=NF;i++) if($i=="src") print $(i+1)}' | head -n 1)
  if [ -z "$LAN_IP" ]; then
    LAN_IP=$(ip addr show 2>/dev/null | grep -o 'inet [0-9.]*' | grep -v '127.0.0.1' | awk '{print $2}' | head -n 1)
  fi
elif command -v hostname >/dev/null 2>&1; then
  LAN_IP=$(hostname -I 2>/dev/null | awk '{print $1}')
fi

# 7. Print Final Status Output
echo "========================================"
echo "           CTF MACHINE READY            "
echo "========================================"
echo "Application: RUNNING"
echo "Port: $APP_PORT"
echo "URL: http://localhost:$APP_PORT"
if [ -n "$LAN_IP" ]; then
  echo "LAN URL: http://${LAN_IP}:$APP_PORT"
fi
echo ""
echo "Docker containers:"
$COMPOSE_CMD ps
echo ""
echo "Database: PERSISTENT (Volume: shopnest-data)"
echo "========================================"
