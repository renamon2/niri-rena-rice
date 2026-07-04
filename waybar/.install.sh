#!/bin/bash
PACKAGE_FOR_MAYBE_VOID_BUT_FOR_VOSTOK_ONE_HUNDRED_PERCENT="Waybar btop kitty wireshark-qt NetworkManager pavucontrol nerd-fonts-symbols-ttf font-firacode"
PACKAGE_FOR_ARCH="just in case not support now"
if command -v xbps-install &> /dev/null; then
    PKG_MANAGER="xbps-install"
    PACKAGES=$PACKAGE_FOR_MAYBE_VOID_BUT_FOR_VOSTOK_ONE_HUNDRED_PERCENT
elif command -v pacman &> /dev/null; then
    PKG_MANAGER="pacman --noconfirm -Sy"
fi

echo "need install $PACKAGE_FOR_MAYBE_VOID_BUT_FOR_VOSTOK_ONE_HUNDRED_PERCENT"
sudo $PKG_MANAGER -Sy $PACKAGE_FOR_MAYBE_VOID_BUT_FOR_VOSTOK_ONE_HUNDRED_PERCENT

echo "$PACKAGE_FOR_ARCH"
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
REPO1_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/waybar/config.jsonc"
REPO2_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/waybar/style.css"
mkdir -p "$DEST_DIR"
cp /etc/xdg/waybar/style.css "$DEST_DIR"
cp /etc/xdg/waybar/waybar.jsonc "$DEST_DIR"
if [ -f "$DEST_DIR/config.jsonc" ]; then
    mv "$DEST_DIR/config.jsonc" "$DEST_DIR/config.jsonc.bak"
    echo "Backup created: $DEST_DIR/config.jsonc.bak"
else
    echo "Existing config not found, skipping backup."
fi
if [ -f "$DEST_DIR/style.css" ]; then
    mv "$DEST_DIR/style.css" "$DEST_DIR/style.css.bak"
    echo "Backup created: $DEST_DIR/style.css.bak"
else
    echo "Existing config not found, skipping backup."
fi
curl -L -o "$DEST_DIR/config.jsonc" "$REPO1_URL"
curl -L -o "$DEST_DIR/style.css" "$REPO2_URL"
echo "File updated successfully"
