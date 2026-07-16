echo -e "Hey, look who made it to the best part—it’s you, gorgeous. \nSo, let’s get *niri* set up just for you. You don’t mind, do you? \nJust a heads-up: if you press Ctrl+C, it’ll stop, and you’ll have to start all over again..."
URL=https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/files/config.kdl
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/niri"
CFG="$DEST_DIR/config.kdl"
#Бэкап существующей конфигурации, если существует
# EN: Backup existing configuration, if it exists
if [ -d "$CFG" ]; then
    mv "$CFG" "$CFG.bak"
    echo "niri config.kdl has been backed up to $CFG.bak."
else
    mkdir -p "$DEST_DIR"
    echo "$DEST_DIR directory created."
fi
# Установка конфигурации
# EN: Install configuration
if [ -d "$DEST_DIR" ] && command -v niri >/dev/null 2>&1; then
    curl -sSL "$URL" -o "$DEST_DIR/config.kdl"
    echo "$CFG has been installed."
else
    echo "Hey, this is part of the script at https://github.com/renamon2/niri-rena-rice/tree/main. Use the command in the README.md."
    sleep 7
    xdg-open "https://github.com/renamon2/niri-rena-rice/tree/main"
    exit 1
fi
# Добавление help.html
# EN: Add help.html
sed "s/user/$USER/g" "$CFG" > "$CFG.tmp" && mv "$CFG.tmp" "$CFG"
echo "$CFG has been updated."
URL=https://githubusercontent.com/renamon2/niri-rena-rice/raw/refs/heads/main/help.tar.gz
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/niri/help"
if [ -d "$DEST_DIR" ]; then
    curl -sSL "$URL" -o "$DEST_DIR/help.tar.gz"
    echo "niri help has been installed."
    tar -xzf "$DEST_DIR/help.tar.gz" -C "$DEST_DIR"
    rm "$DEST_DIR/help.tar.gz"
    echo "niri help has been extracted."
    echo "niri help has been updated. When you start niri with new settings, then run Super+F1."
else
    mkdir -p "$DEST_DIR"
    echo "$DEST_DIR directory created."
    curl -sSL "$URL" -o "$DEST_DIR/help.tar.gz"
    echo "niri help has been installed."
    tar -xzf "$DEST_DIR/help.tar.gz" -C "$DEST_DIR"
    rm "$DEST_DIR/help.tar.gz"
    echo "niri help has been extracted."
    echo "niri help has been updated. When you start niri with new settings, then run Super+F1."
fi
# Добавление обоев
# EN: Add wallpapers
URL1=https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/assets/toki_in_space-0.3_overview.png
URL2=https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/assets/toki_in_space-blurred.png
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/niri/wallpaper/awww/"
mkdir -p $DEST_DIR
curl -sSL "$URL1" -o "$DEST_DIR/toki_in_space-0.3_overview.png"
curl -sSL "$URL2" -o "$DEST_DIR/toki_in_space-blurred.png"
echo "niri wallpapers have been installed."

# Добавляем niri-rice.desktop, если systemctl не найден
# EN: Add niri-rice.desktop, if systemctl is not found
DEST_DIR="/usr/share/wayland-sessions"
if command -v systemctl --version &>/dev/null; then
    echo "systemctl found. Skipping niri-rice.desktop creation for runit."
else
    echo "systemctl not found. Creating niri-rice.desktop for runit."
    touch "$DEST_DIR/niri-rice.desktop"
    echo "niri-rice.desktop has been created."
    sudo tee "$DEST_DIR/niri-rice.desktop" > /dev/null <<EOF
[Desktop Entry]
Name=Niri (Rice)
Comment=A scrollable-tiling Wayland compositor
Exec=niri
Type=Application
DesktopNames=rice-niri
EOF
    echo "niri-rice.desktop has been written."
    sudo chmod 644 "$DEST_DIR/niri-rice.desktop"
    sudo chown root:root "$DEST_DIR/niri-rice.desktop"
    echo "niri-rice.desktop ownership has been set."
fi