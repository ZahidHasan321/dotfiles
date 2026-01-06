# -----------------------------------------------------
# Modular ZSH Configuration
# -----------------------------------------------------
# This .zshrc sources modular configuration files from ~/.config/zshrc/
# Files are loaded in numeric order: 00-init, 20-customization, 25-aliases, etc.

# Source all configuration files from ~/.config/zshrc/ in order
if [ -d "$HOME/.config/zshrc" ]; then
    for config_file in "$HOME/.config/zshrc"/*; do
        if [ -f "$config_file" ]; then
            source "$config_file"
        fi
    done
fi

# Load development environment configuration
DEV_CONFIG_FILE="/run/host/home/zahid/dotfiles/.config/dev-env/config"
if [ -f "$DEV_CONFIG_FILE" ]; then
    source "$DEV_CONFIG_FILE"
fi

# UV cache directory - only in distrobox to keep host clean
if [ -f /run/host/etc/hostname ]; then
    # In distrobox - use configured cache partition
    if [ -n "$DEV_CACHE_PARTITION" ]; then
        export UV_CACHE_DIR="$DEV_CACHE_PARTITION/.uv_cache"
    else
        # Fallback to home if not configured
        export UV_CACHE_DIR="$HOME/.cache/uv"
    fi
fi
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"



# pnpm - conditional setup for distrobox vs host
if [ -f /run/host/etc/hostname ]; then
    # In distrobox - use distrobox-specific pnpm
    export PNPM_HOME="$HOME/.local/share/pnpm"
else
    # On host - use host pnpm (if installed)
    export PNPM_HOME="$HOME/.local/share/pnpm"
fi
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# pnpm
export PNPM_HOME="/home/zahid/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
