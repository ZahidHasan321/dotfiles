#!/bin/bash
# -----------------------------------------------------
# Setup Distrobox Exports
# -----------------------------------------------------
# Run this script INSIDE the fedora-dev distrobox to export
# dev tools to the host's ~/.local/bin
#
# Usage: fdev -- ~/dotfiles/scripts/setup-distrobox-exports.sh
# -----------------------------------------------------

set -e

EXPORT_PATH="$HOME/.local/bin"

# Ensure export path exists
mkdir -p "$EXPORT_PATH"

echo "Exporting dev tools from distrobox to $EXPORT_PATH..."

# Node.js ecosystem
distrobox-export --bin /usr/bin/node --export-path "$EXPORT_PATH"
distrobox-export --bin /usr/bin/npm --export-path "$EXPORT_PATH"
distrobox-export --bin /usr/bin/npx --export-path "$EXPORT_PATH"
distrobox-export --bin /usr/bin/pnpm --export-path "$EXPORT_PATH"

# Python ecosystem
distrobox-export --bin /usr/bin/uv --export-path "$EXPORT_PATH"
distrobox-export --bin /usr/bin/uvx --export-path "$EXPORT_PATH"
distrobox-export --bin /usr/bin/python3 --export-path "$EXPORT_PATH"

echo ""
echo "Done! Exported tools:"
ls -la "$EXPORT_PATH"/{node,npm,npx,pnpm,uv,uvx,python3} 2>/dev/null
