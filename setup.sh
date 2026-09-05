#!/usr/bin/env bash
set -e

# Support PORT env var, HOST_PORT env var, or first positional argument (default: 9000)
APP_PORT="${1:-${PORT:-${HOST_PORT:-9000}}}"
export HOST_PORT="$APP_PORT"

echo "========================================"
echo "    ShopNest CTF Deployment System     "
echo "========================================"
echo "[ShopNest CTF] Configuring CTF machine on host port: $APP_PORT"
echo "[ShopNest CTF] Checking Docker..."

# Determine sudo prefix if not running as root
SUDO_PREFIX=""
if [ "$(id -u 2>/dev/null || echo 1)" -ne 0 ] && command -v sudo >/dev/null 2>&1; then
  SUDO_PREFIX="sudo "
fi

# 1. Detect and install Docker if missing
if ! command -v docker >/dev/null 2>&1; then
  echo "[ShopNest CTF] Docker is not installed on this system."
  if command -v apt-get >/dev/null 2>&1; then
    echo "[ShopNest CTF] Detected Debian/Ubuntu/Kali system. Installing Docker..."
    ${SUDO_PREFIX}apt-get update -y || true
    ${SUDO_PREFIX}apt-get install -y docker.io || true
    ${SUDO_PREFIX}systemctl enable --now docker 2>/dev/null || ${SUDO_PREFIX}service docker start 2>/dev/null || true
  elif command -v dnf >/dev/null 2>&1; then
    echo "[ShopNest CTF] Detected Fedora/RHEL system. Installing Docker..."
    ${SUDO_PREFIX}dnf install -y docker docker-compose-plugin || true
    ${SUDO_PREFIX}systemctl enable --now docker 2>/dev/null || true
  elif command -v pacman >/dev/null 2>&1; then
    echo "[ShopNest CTF] Detected Arch Linux system. Installing Docker..."
    ${SUDO_PREFIX}pacman -Sy --noconfirm docker docker-compose || true
    ${SUDO_PREFIX}systemctl enable --now docker 2>/dev/null || true
  else
    echo "[!] Please install Docker before running this script:"
    echo "    - Debian / Ubuntu / Kali: sudo apt update && sudo apt install -y docker.io docker-compose"
    echo "    - Fedora: sudo dnf install -y docker docker-compose-plugin && sudo systemctl enable --now docker"
    echo "    - Arch Linux: sudo pacman -S docker docker-compose && sudo systemctl enable --now docker"
    echo "    - Official Docker script: curl -fsSL https://get.docker.com | sh"
    exit 1
  fi
fi

# 2. Check Docker daemon access and permissions
DOCKER_BIN="docker"
USE_SUDO_FOR_DOCKER=0

if docker ps >/dev/null 2>&1; then
  DOCKER_BIN="docker"
elif [ -n "$SUDO_PREFIX" ] && sudo docker ps >/dev/null 2>&1; then
  DOCKER_BIN="sudo docker"
  USE_SUDO_FOR_DOCKER=1
else
  # Attempt to start the docker daemon
  echo "[ShopNest CTF] Attempting to start Docker daemon..."
  ${SUDO_PREFIX}systemctl start docker 2>/dev/null || ${SUDO_PREFIX}service docker start 2>/dev/null || true

  if docker ps >/dev/null 2>&1; then
    DOCKER_BIN="docker"
  elif [ -n "$SUDO_PREFIX" ] && sudo docker ps >/dev/null 2>&1; then
    DOCKER_BIN="sudo docker"
    USE_SUDO_FOR_DOCKER=1
  else
    echo "[!] Error: Cannot connect to the Docker daemon."
    echo "    Please ensure Docker service is running: sudo systemctl start docker"
    exit 1
  fi
fi

echo "[ShopNest CTF] Docker: OK"

# 3. Detect and install Docker Compose if missing
COMPOSE_CMD=""
if $DOCKER_BIN compose version >/dev/null 2>&1; then
  COMPOSE_CMD="${DOCKER_BIN} compose"
elif command -v docker-compose >/dev/null 2>&1 && [ $USE_SUDO_FOR_DOCKER -eq 0 ] && docker-compose version >/dev/null 2>&1; then
  COMPOSE_CMD="docker-compose"
elif [ -n "$SUDO_PREFIX" ] && command -v docker-compose >/dev/null 2>&1 && sudo docker-compose version >/dev/null 2>&1; then
  COMPOSE_CMD="sudo docker-compose"
else
  echo "[ShopNest CTF] Docker Compose not found. Attempting installation..."
  if command -v apt-get >/dev/null 2>&1; then
    ${SUDO_PREFIX}apt-get install -y docker-compose-plugin 2>/dev/null || \
    ${SUDO_PREFIX}apt-get install -y docker-compose 2>/dev/null || \
    ${SUDO_PREFIX}apt-get install -y docker-compose-v2 2>/dev/null || true
  fi

  if $DOCKER_BIN compose version >/dev/null 2>&1; then
    COMPOSE_CMD="${DOCKER_BIN} compose"
  elif command -v docker-compose >/dev/null 2>&1 && [ $USE_SUDO_FOR_DOCKER -eq 0 ] && docker-compose version >/dev/null 2>&1; then
    COMPOSE_CMD="docker-compose"
  elif [ -n "$SUDO_PREFIX" ] && command -v docker-compose >/dev/null 2>&1 && sudo docker-compose version >/dev/null 2>&1; then
    COMPOSE_CMD="sudo docker-compose"
  else
    # Direct binary fallback download from official Docker release
    echo "[ShopNest CTF] Downloading Docker Compose CLI plugin directly..."
    ARCH="$(uname -m 2>/dev/null || echo x86_64)"
    case "$ARCH" in
      x86_64) COMPOSE_ARCH="x86_64" ;;
      aarch64|arm64) COMPOSE_ARCH="aarch64" ;;
      armv7l) COMPOSE_ARCH="armv7" ;;
      *) COMPOSE_ARCH="x86_64" ;;
    esac
    ${SUDO_PREFIX}mkdir -p /usr/local/lib/docker/cli-plugins 2>/dev/null || true
    ${SUDO_PREFIX}curl -SL "https://github.com/docker/compose/releases/latest/download/docker-compose-linux-${COMPOSE_ARCH}" -o /usr/local/lib/docker/cli-plugins/docker-compose 2>/dev/null || true
    ${SUDO_PREFIX}chmod +x /usr/local/lib/docker/cli-plugins/docker-compose 2>/dev/null || true

    if $DOCKER_BIN compose version >/dev/null 2>&1; then
      COMPOSE_CMD="${DOCKER_BIN} compose"
    fi
  fi
fi

if [ -z "$COMPOSE_CMD" ]; then
  echo "[!] Error: Docker Compose is required. Please install 'docker-compose' or 'docker-compose-plugin'."
  exit 1
fi

echo "[ShopNest CTF] Docker Compose: OK"

# 4. Build and start containers
echo "[ShopNest CTF] Building image..."
$COMPOSE_CMD build

echo "[ShopNest CTF] Starting container..."
$COMPOSE_CMD up -d

# 5. Startup & Health Verification
echo "[ShopNest CTF] Waiting for application..."
READY=0
SQLITE_READY=0
MAX_RETRIES=35
RETRY_COUNT=0

while [ $RETRY_COUNT -lt $MAX_RETRIES ]; do
  # Check if HTTP endpoint responds
  HTTP_CODE=""
  if command -v curl >/dev/null 2>&1; then
    HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://127.0.0.1:${APP_PORT}/" 2>/dev/null || true)
  elif command -v wget >/dev/null 2>&1; then
    if wget -q -O - "http://127.0.0.1:${APP_PORT}/" >/dev/null 2>&1; then
      HTTP_CODE="200"
    fi
  fi

  if [ "$HTTP_CODE" = "200" ] || [ "$HTTP_CODE" = "302" ] || [ "$HTTP_CODE" = "304" ]; then
    READY=1
    break
  fi

  # Fallback to checking docker container health status
  HEALTH_STATUS=$($DOCKER_BIN inspect --format='{{json .State.Health.Status}}' shopnest-ctf 2>/dev/null || echo '""')
  if [ "$HEALTH_STATUS" = "\"healthy\"" ]; then
    READY=1
    break
  fi

  RETRY_COUNT=$((RETRY_COUNT + 1))
  printf "."
  sleep 2
done

echo ""

if [ $READY -ne 1 ]; then
  echo ""
  echo "[!] ERROR: Application failed to respond on port $APP_PORT within 70 seconds."
  echo "[*] Container logs:"
  $COMPOSE_CMD logs --tail 40
  echo ""
  echo "[*] Container status:"
  $COMPOSE_CMD ps
  exit 1
fi

# Verify SQLite status from logs
if $COMPOSE_CMD logs shopnest 2>&1 | grep -q "SQLite connected"; then
  echo "[ShopNest CTF] SQLite: connected"
else
  echo "[ShopNest CTF] SQLite: initialized"
fi

echo "[ShopNest CTF] Application: ready"

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
echo ""
echo "========================================"
echo "           ShopNest CTF READY           "
echo "========================================"
echo "ShopNest CTF is running:"
echo "Local:   http://localhost:$APP_PORT"
if [ -n "$LAN_IP" ]; then
  echo "Network: http://${LAN_IP}:$APP_PORT"
fi
echo ""
echo "Database: Persistent (Docker volume: shopnest-data)"
echo "Container: shopnest-ctf"
echo "========================================"
