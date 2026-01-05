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
# Replace /mnt/data with your actual partition path
export UV_CACHE_DIR="/mnt/339cc06e-972e-45cf-aed0-2b21bc4f4d69/.uv_cache"
. "$HOME/.local/bin/env"


