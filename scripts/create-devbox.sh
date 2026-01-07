#!/bin/bash
# -----------------------------------------------------
# Create Development Distrobox
# -----------------------------------------------------
# Creates a new distrobox with dev tools and exports them
#
# Usage:
#   ./create-devbox.sh                     # Interactive
#   ./create-devbox.sh fedora-dev fedora   # With args
#   ./create-devbox.sh mybox ubuntu:24.04  # Custom image
# -----------------------------------------------------

set -e

# Available distro shortcuts
declare -A DISTROS=(
  ["fedora"]="registry.fedoraproject.org/fedora:latest"
  ["fedora-toolbox"]="registry.fedoraproject.org/fedora-toolbox:latest"
  ["ubuntu"]="docker.io/library/ubuntu:latest"
  ["ubuntu-24.04"]="docker.io/library/ubuntu:24.04"
  ["ubuntu-22.04"]="docker.io/library/ubuntu:22.04"
  ["debian"]="docker.io/library/debian:latest"
  ["arch"]="docker.io/library/archlinux:latest"
)

# Package managers and package names per distro family
get_install_cmd() {
  local image="$1"
  case "$image" in
  *fedora* | *centos* | *rhel* | *alma* | *rocky*)
    echo "dnf install -y git zsh curl wget nodejs pnpm python3 uv docker-cli docker-compose gcc gcc-c++ make openssl openssl-devel cargo"
    ;;
  *ubuntu* | *debian*)
    echo "apt-get update && apt-get install -y git zsh curl wget nodejs npm python3 python3-pip docker.io docker-compose build-essential libssl-dev ca-certificates cargo"
    ;;
  *archlinux* | *arch:*)
    echo "pacman -Syu --noconfirm git zsh curl wget nodejs npm python uv docker-cli docker-compose base-devel openssl cargo"
    ;;
  *)
    echo "echo 'Unknown distro - install packages manually'"
    ;;
  esac
}

# Get name
if [ -n "$1" ]; then
  NAME="$1"
else
  read -p "Distrobox name [dev]: " NAME
  NAME="${NAME:-dev}"
fi

# Get image
if [ -n "$2" ]; then
  INPUT_IMAGE="$2"
else
  echo ""
  echo "Available distros:"
  for key in "${!DISTROS[@]}"; do
    echo "  $key"
  done
  echo ""
  read -p "Distro or full image URL [fedora]: " INPUT_IMAGE
  INPUT_IMAGE="${INPUT_IMAGE:-fedora}"
fi

# Resolve image
if [ -n "${DISTROS[$INPUT_IMAGE]}" ]; then
  IMAGE="${DISTROS[$INPUT_IMAGE]}"
else
  IMAGE="$INPUT_IMAGE"
fi

# Check for Docker on host
DOCKER_VOLUME=""
HAS_DOCKER=false
if [ -S /var/run/docker.sock ]; then
  DOCKER_VOLUME="--volume /var/run/docker.sock:/var/run/docker.sock:rw"
  HAS_DOCKER=true
fi

# Check for dev cache partition (for pnpm, uv caches)
CACHE_VOLUME=""
DEV_CONFIG_FILE="$HOME/dotfiles/.config/dev-env/config"
if [ -f "$DEV_CONFIG_FILE" ]; then
  source "$DEV_CONFIG_FILE"
  if [ -n "$DEV_CACHE_PARTITION" ] && [ -d "$DEV_CACHE_PARTITION" ]; then
    CACHE_VOLUME="--volume $DEV_CACHE_PARTITION:$DEV_CACHE_PARTITION:rw"
  fi
fi

INSTALL_CMD=$(get_install_cmd "$IMAGE")

# Remove docker packages from install if docker not on host
if [ "$HAS_DOCKER" = false ]; then
  INSTALL_CMD=$(echo "$INSTALL_CMD" | sed 's/docker-cli//g; s/docker-compose//g; s/docker\.io//g')
fi

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Creating Distrobox"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Name:  $NAME"
echo "  Image: $IMAGE"
if [ "$HAS_DOCKER" = true ]; then
  echo "  Docker: Yes (socket will be mounted)"
else
  echo "  Docker: No (not found on host)"
fi
if [ -n "$CACHE_VOLUME" ]; then
  echo "  Cache:  $DEV_CACHE_PARTITION"
fi
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""

# Create the distrobox

distrobox create \
  --name "$NAME" \
  --image "$IMAGE" \
  --pull \
  --yes \
  ${DOCKER_VOLUME:+$DOCKER_VOLUME} \
  ${CACHE_VOLUME:+$CACHE_VOLUME}

echo ""
echo "Installing dev packages..."
distrobox enter "$NAME" -- sudo sh -c "$INSTALL_CMD"

echo ""
echo "Installing Claude Code..."
distrobox enter "$NAME" -- npm install -g @anthropic-ai/claude-code 2>/dev/null || true

echo ""
echo "Exporting dev tools..."
EXPORT_PATH="$HOME/.local/bin"
mkdir -p "$EXPORT_PATH"

# Export available tools (some may not exist depending on distro)
TOOLS="node npm npx pnpm python3 uv uvx claude"
if [ "$HAS_DOCKER" = true ]; then
  TOOLS="$TOOLS docker docker-compose"
fi

for tool in $TOOLS; do
  echo "  Checking $tool..."
  distrobox enter "$NAME" -- sh -c "
        if command -v '$tool' >/dev/null 2>&1; then
            distrobox-export --bin \"\$(which '$tool')\" --export-path '$EXPORT_PATH'
        fi
    " 2>/dev/null || true
done

echo ""
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done!"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo ""
echo "Enter with:  distrobox enter $NAME"
echo "Or add alias to .zshrc:"
echo "  alias ${NAME}='distrobox enter $NAME'"
echo ""
