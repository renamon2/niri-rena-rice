#!/bin/bash
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/swaync"
REPO1_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/swaync/config.json"
REPO2_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/swaync/style.css"
if command -v swaync &> /dev/null; then
    echo "NICE! swaync was already installed."
else
    echo "rofi not found. Trying to install..."
    if command -v xbps-install &> /dev/null; then
        sudo xbps-install -Sy SwayNotificationCenter
    elif command -v pacman &> /dev/null; then
        sudo pacman --noconfirm -Sy swaync
    else
        echo "Supported package manager not found. Download rofi yourself."
    fi
fi
mkdir -p "$DEST_DIR"
if [ -f "$DEST_DIR/config.json" ]; then
    mv "$DEST_DIR/config.json" "$DEST_DIR/config.json.bak"
    echo "Backup created: $DEST_DIR/config.json.bak"
else
    echo "Existing config not found, skipping backup."
fi
if [ -f "$DEST_DIR/style.css" ]; then
    mv "$DEST_DIR/style.css" "$DEST_DIR/style.css.bak"
    echo "Backup created: $DEST_DIR/style.css.bak"
else
    echo "Existing config not found, skipping backup."
fi
curl -L -o "$DEST_DIR/config.json" "$REPO1_URL"
curl -L -o "$DEST_DIR/style.css" "$REPO2_URL"
echo "File updated successfully"
