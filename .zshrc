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

# Load uv env if present
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"

# Dev tools (pnpm, uv, etc.) are configured in ~/.config/zshrc/15-dev-tools
# They are only available inside distrobox to keep the host clean

# pnpm
export PNPM_HOME="/home/zahid/.local/share/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
