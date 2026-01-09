#!/bin/bash
# ---------------------------------------------------------------------------
#  create-devbox.sh
# ---------------------------------------------------------------------------
set -euo pipefail

# ---------------------------------------------------------------------------
#  1.  Distro Registry
# ---------------------------------------------------------------------------
declare -A DISTROS=(
  [fedora]="registry.fedoraproject.org/fedora:latest"
  [fedora - toolbox]="registry.fedoraproject.org/fedora-toolbox:latest"
  [ubuntu]="docker.io/library/ubuntu:latest"
  [ubuntu - 24.04]="docker.io/library/ubuntu:24.04"
  [ubuntu - 22.04]="docker.io/library/ubuntu:22.04"
  [debian]="docker.io/library/debian:latest"
  [arch]="docker.io/library/archlinux:latest"
)

# ---------------------------------------------------------------------------
#  2.  System Packages (To be installed as ROOT)
# ---------------------------------------------------------------------------
get_system_packages() {
  local img=$1
  case "$img" in
  *fedora* | *centos* | *rhel* | *alma* | *rocky*)
    # Note: 'npm' includes nodejs in many repos, but specifying both is safer
    echo "dnf install -y git zsh curl wget nodejs npm python3 pip docker-cli docker-compose gcc gcc-c++ make openssl openssl-devel cargo"
    ;;
  *ubuntu* | *debian*)
    echo "apt-get update && apt-get install -y git zsh curl wget nodejs npm python3 python3-pip docker.io docker-compose build-essential libssl-dev ca-certificates cargo"
    ;;
  *archlinux* | *arch:*)
    echo "pacman -Syu --noconfirm git zsh curl wget nodejs npm python python-pip docker-cli docker-compose base-devel openssl cargo"
    ;;
  *) echo "echo 'Unknown distro – install packages manually'" ;;
  esac
}

# ---------------------------------------------------------------------------
#  3.  Additional Flags (distrobox handles devices, display, GPU automatically)
# ---------------------------------------------------------------------------
ADDITIONAL_FLAGS=()

# ---------------------------------------------------------------------------
#  4.  Input Handling
# ---------------------------------------------------------------------------
NAME=${1:-}
if [[ -z "$NAME" ]]; then
  read -rp "Distrobox name [dev]: " NAME
  NAME=${NAME:-dev}
fi

INPUT_IMG=${2:-}
if [[ -z "$INPUT_IMG" ]]; then
  echo
  echo "Available short-names:"
  printf '  %s\n' "${!DISTROS[@]}" | sort
  echo
  read -rp "Distro or full image URL [fedora]: " INPUT_IMG
  INPUT_IMG=${INPUT_IMG:-fedora}
fi
IMAGE=${DISTROS[$INPUT_IMG]:-$INPUT_IMG}

# ---------------------------------------------------------------------------
#  5.  Dev Cache Partition Selection
# ---------------------------------------------------------------------------
DEV_CFG_DIR="$HOME/dotfiles/.config/dev-env"
DEV_CFG="$DEV_CFG_DIR/config"
DEV_CACHE_PARTITION=""

# Check if config already exists
if [[ -f "$DEV_CFG" ]]; then
  # shellcheck source=/dev/null
  source "$DEV_CFG"
fi

# If not set, prompt user to select a partition
if [[ -z "${DEV_CACHE_PARTITION:-}" ]]; then
  echo
  echo "Select a partition for dev cache (pnpm store, etc.):"
  echo

  # Get mounted partitions (exclude tmpfs, devtmpfs, etc.)
  mapfile -t PARTITIONS < <(lsblk -rno MOUNTPOINT,SIZE,FSTYPE | awk '$1 != "" && $3 !~ /tmpfs|devtmpfs|efivarfs|squashfs/ {print $1 "|" $2 "|" $3}' | sort -u)

  if [[ ${#PARTITIONS[@]} -eq 0 ]]; then
    echo "  No suitable partitions found."
  else
    for i in "${!PARTITIONS[@]}"; do
      IFS='|' read -r mount size fstype <<<"${PARTITIONS[$i]}"
      printf "  %d) %-30s %8s  %s\n" "$((i + 1))" "$mount" "$size" "$fstype"
    done
  fi

  echo
  echo "  s) Skip (no cache partition)"
  echo
  read -rp "Selection [s]: " PART_CHOICE
  PART_CHOICE=${PART_CHOICE:-s}

  if [[ "$PART_CHOICE" != "s" && "$PART_CHOICE" =~ ^[0-9]+$ ]]; then
    idx=$((PART_CHOICE - 1))
    if [[ $idx -ge 0 && $idx -lt ${#PARTITIONS[@]} ]]; then
      IFS='|' read -r DEV_CACHE_PARTITION _ _ <<<"${PARTITIONS[$idx]}"

      # Save to config
      mkdir -p "$DEV_CFG_DIR"
      echo "DEV_CACHE_PARTITION=\"$DEV_CACHE_PARTITION\"" >"$DEV_CFG"
      echo "  → Saved: $DEV_CACHE_PARTITION"
    fi
  else
    echo "  → Skipping cache partition"
  fi
fi

# ---------------------------------------------------------------------------
#  6.  Docker & Volume Config
# ---------------------------------------------------------------------------
DOCKER_FLAGS=()
[[ -S /var/run/docker.sock ]] && DOCKER_FLAGS+=(--volume /var/run/docker.sock:/var/run/docker.sock:rw)

CACHE_FLAGS=()
if [[ -n "${DEV_CACHE_PARTITION:-}" && -d "$DEV_CACHE_PARTITION" ]]; then
  CACHE_FLAGS+=(--volume "$DEV_CACHE_PARTITION:$DEV_CACHE_PARTITION:rw")
fi

# ---------------------------------------------------------------------------
#  7.  Prepare Command Strings
# ---------------------------------------------------------------------------
SYSTEM_INSTALL_CMD=$(get_system_packages "$IMAGE")

# If we didn't mount the docker socket, remove docker tools from install list
# to avoid errors or useless packages
if [[ ${#DOCKER_FLAGS[@]} -eq 0 ]]; then
  SYSTEM_INSTALL_CMD=$(sed 's/docker-cli//g; s/docker-compose//g; s/docker\.io//g' <<<"$SYSTEM_INSTALL_CMD")
fi

# ---------------------------------------------------------------------------
#  8.  Create Container
# ---------------------------------------------------------------------------
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Creating distrobox"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Name : $NAME"
echo "  Image: $IMAGE"
[[ ${#DOCKER_FLAGS[@]} -gt 0 ]] && echo "  Docker socket: yes" || echo "  Docker socket: no"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo

distrobox create \
  --name "$NAME" \
  --image "$IMAGE" \
  --pull \
  --yes \
  "${DOCKER_FLAGS[@]}" \
  "${CACHE_FLAGS[@]}" \
  "${ADDITIONAL_FLAGS[@]}"

# ---------------------------------------------------------------------------
#  9.  Install Packages
# ---------------------------------------------------------------------------
echo
echo "STEP 1: Installing System Packages..."
distrobox enter "$NAME" -- sudo sh -c "$SYSTEM_INSTALL_CMD"

echo
echo "STEP 2: Installing Shell Tools (oh-my-zsh, plugins)..."
distrobox enter "$NAME" -- sh -c '
  # Install oh-my-zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
  fi

  ZSH_CUSTOM="${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}"

  # Install zsh-autosuggestions
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH_CUSTOM/plugins/zsh-autosuggestions"
  fi

  # Install zsh-syntax-highlighting
  if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting"
  fi
'

echo
echo "STEP 3: Installing User Tools (eza, uv, pnpm)..."
distrobox enter "$NAME" -- sudo sh -c '
  # Install eza via cargo to /usr/local
  CARGO_HOME=/usr/local/cargo cargo install eza
  ln -sf /usr/local/cargo/bin/eza /usr/local/bin/eza

  # Install uv to /usr/local/bin
  curl -LsSf https://astral.sh/uv/install.sh | INSTALLER_NO_MODIFY_PATH=1 UV_INSTALL_DIR=/usr/local/bin sh

  # Install pnpm globally via npm (container-only)
  npm install -g pnpm
'

echo
echo "STEP 4: Setting default shell to zsh..."
distrobox enter "$NAME" -- sh -c 'sudo chsh -s "$(which zsh)" "$USER"'

# ---------------------------------------------------------------------------
#  10. Done
# ---------------------------------------------------------------------------
echo
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo "  Done!  Enter with:  distrobox enter $NAME"
echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
echo
