#!/bin/bash
PACKAGE="rofi"
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rofi"
REPO_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/rofi/config.rasi"

if command -v rofi &> /dev/null; then
    echo "NICE! rofi was already installed."
else
    echo "rofi not found. Trying to install..."
    if command -v xbps-install &> /dev/null; then
        sudo xbps-install -Sy "$PACKAGE"
    elif command -v pacman &> /dev/null; then
        sudo pacman --noconfirm -Sy "$PACKAGE"
    else
        echo "Supported package manager not found. Download rofi yourself."
    fi
fi
mkdir -p "$DEST_DIR"
if [ -f "$DEST_DIR/config.rasi" ]; then
    mv "$DEST_DIR/config.rasi" "$DEST_DIR/config.rasi.bak"
    echo "Backup created: $DEST_DIR/config.rasi.bak"
else
    echo "Existing config not found, skipping backup."
fi
curl -L -o "$DEST_DIR/config.rasi" "$REPO_URL"
echo "File updated successfully"
