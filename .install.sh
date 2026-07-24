#!/bin/bash
#ask_yes_no() {
#    read -t 5 -p "$1 (Y/n) [Auto-yes in 5s]: " yn < /dev/tty
#    if [ -z "$yn" ]; then
#        echo -e "\nTimeout or Enter pressed! Defaulting to: YES"
#        return 0
#    fi
#    case $yn in
#        [YyДд]* | [Yy][Ee][Ss] | [Дд][Аа] | "yep" | "yeah" | "sure" ) 
#            return 0 
#            ;;
#        [NnНн]* | [Nn][Oo] | [Нн][Ее][Тт] | "nope" | "nay" ) 
#            return 1 
#            ;;
#        * ) 
#            echo "Unknown response. Defaulting to: NO"
#            return 1 
#            ;;
#    esac
#}

# pkg mng
if command -v xbps-install && grep -rq "vostoklinux.org" /etc/xbps.d/ 2>/dev/null || grep -rq "vostoklinux.org" /usr/share/xbps.d/ 2>/dev/null || grep -q "vostok" /etc/os-release 2>/dev/null; then
    PACKAGE="niri btop xdg-desktop-portal-wlr dolphin jq wireshark-qt firefox octoxbps zed gwenview ark gucharmap xdg-desktop-portal-gtk qt6-wayland git NetworkManager pavucontrol nerd-fonts-symbols-ttf font-firacode curl qt5-wayland kitty Waybar fish-shell SwayNotificationCenter rofi"
    PKG_MANAGER="xbps-install -Suy"
    sudo $PKG_MANAGER $PACKAGE
    echo "vostok linux repo found"
fi

if command -v niri > /dev/null 2>&1; then
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
REPO_URL="https://github.com/ttys3/oh-my-kitty.git"
mkdir -p "$DEST_DIR"
if [ -d "$DEST_DIR" ] && [ "$(ls -A "$DEST_DIR")" ]; then
    echo "Creating backup..."
    BACKUP_DIR="$HOME/.config/kitty_backup_$(date +%Y%m%d_%H%M%S)"
    mv "$DEST_DIR" "$BACKUP_DIR"
    echo "Backup moved to: $BACKUP_DIR"
fi
git clone "$REPO_URL" "$DEST_DIR"
rm -rf "$DEST_DIR/.git" "$DEST_DIR/.gitignore"
echo "Files updated successfully!"

sed -i 's/^shell_integration .*/shell_integration enabled no-cursor/g' "$DEST_DIR/kitty.conf"

sed -i 's/background_opacity 1.0/background_opacity 0.98/g' "$DEST_DIR/kitty.conf"
cat << 'EOF' >> "$DEST_DIR/kitty.conf"
cursor_shape block
cursor_blink_interval 0.5
cursor_stop_blinking_after 15.0
repaint_delay 8
input_delay 1
sync_to_monitor yes
EOF

sed -i \
  -e 's/^background .*/background #18222e/' \
  -e 's/^foreground .*/foreground #ffffff/' \
  -e 's/^color0 .*/color0 #18222e/' \
  -e 's/^color8 .*/color8 #373f90/' \
  -e 's/^color4 .*/color4 #373f90/' \
  -e 's/^color12 .*/color12 #373f90/' \
  -e 's/^color5 .*/color5 #c372ac/' \
  -e 's/^color13 .*/color13 #c372ac/' \
  "$DEST_DIR/current-theme.conf"

cat << 'EOF' >> "$DEST_DIR/current-theme.conf"
selection_background #c372ac
selection_foreground #373f90
cursor #c372ac
EOF
    echo "Kitty color scheme installed. From https://raw.githubusercontent.com/ttys3/oh-my-kitty and used my theme."
### WAYBAR ###
    DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
    mkdir -p "$DEST_DIR"
    REPO1_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/waybar/config.jsonc"
    REPO2_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/waybar/style.css"
    if [ -f "$DEST_DIR/config.jsonc" ]; then
        mv "$DEST_DIR/config.jsonc" "$DEST_DIR/config.jsonc.bak"
        mv "$DEST_DIR/style.css" "$DEST_DIR/style.css.bak"
        echo "Backup created: $DEST_DIR/style.css.bak and $DEST_DIR/config.jsonc.bak"
    else
        echo "Existing config not found, skipping backup."
    fi
    curl -L -o "$DEST_DIR/config.jsonc" "$REPO1_URL"
    curl -L -o "$DEST_DIR/style.css" "$REPO2_URL"
    echo "Waybar configured"
### THEMES ###
    bash <(curl -sSL https://raw.githubusercontent.com/renamon2/kvantum-rena/refs/heads/master/.install.sh)
    echo "qt and gtk is configured"
### NOTIFICATION (SWAYNC) ###
    DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/swaync"
    REPO1_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/swaync/config.json"
    REPO2_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/swaync/style.css"
    mkdir -p "$DEST_DIR"
    if [ -f "$DEST_DIR/config.json" ]; then
        mv "$DEST_DIR/config.json" "$DEST_DIR/config.json.bak"
        mv "$DEST_DIR/style.css" "$DEST_DIR/style.css.bak"
        echo "Backup created: $DEST_DIR/config.json.bak and $DEST_DIR/style.css.bak"
    else
        echo "Existing config not found, skipping backup."
    fi
    curl -L -o "$DEST_DIR/config.json" "$REPO1_URL"
    curl -L -o "$DEST_DIR/style.css" "$REPO2_URL"
    echo "Notification is configured"
### DMENU (ROFI) ###
    DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rofi"
    REPO_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/rofi/config.rasi"
    mkdir -p "$DEST_DIR"
    if [ -f "$DEST_DIR/config.rasi" ]; then
        mv "$DEST_DIR/config.rasi" "$DEST_DIR/config.rasi.bak"
        echo "Backup created: $DEST_DIR/config.rasi.bak"
    else
        echo "Existing config not found, skipping backup."
    fi
    curl -L -o "$DEST_DIR/config.rasi" "$REPO_URL"
    echo "rofi is configured"
### SHELL (FISH) ###
    URL="https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"
    DIST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fish"
    mkdir -p "$DIST_DIR"
    echo "make directory $DIST_DIR"
    echo "Installing fisher..."
    fish -c "curl -sL $URL | source && fisher install jorgebucaran/fisher"
    echo "Fisher installed successfully."
cat << 'EOF' > "$DIST_DIR/config.fish"
set -g fish_greeting "!YOU ARE IN fish-shell!"

set -gx EDITOR zed
set -gx TERMINAL kitty

abbr -a fetch fastfetch
abbr -a cl clear
abbr -a upd "sudo xbps-install -Suy"
abbr -a "pacman-S" "sudo xbps-install -S"
abbr -a "pacman-R" "sudo xbps-remove -R"
abbr -a "reboot" "sudo reboot"
abbr -a "off" "sudo shutdown -h now"
abbr -a "msg" "niri msg"
EOF
    echo "fish is configured"
### NIRI CONFIGARATION ###
    DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/niri"
    HELP_DIR="$DEST_DIR/help"
    CFG="$DEST_DIR/config.kdl"
    WALL_DIR="$DEST_DIR/wallpaper/awww/"
    URL1="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/assets/toki_in_space-0.3_overview.png"
    URL2="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/assets/toki_in_space-blurred.png"
    URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/files/config.kdl"
    URL_HELP="https://raw.githubusercontent.com/renamon2/niri-rena-rice/main/help.tar.gz"
    mkdir -p "$DEST_DIR"
    mkdir -p "$HELP_DIR"
    mkdir -p "$WALL_DIR"
    if [ -f "$CFG" ]; then
        mv "$CFG" "$CFG.bak"
        echo "niri config.kdl has been backed up to $CFG.bak."
    fi
    if command -v niri >/dev/null 2>&1; then
        curl -sSL "$URL" -o "$CFG"
        echo "$CFG has been installed."
    fi
    sed "s/user/$USER/g" "$CFG" > "$CFG.tmp" && mv "$CFG.tmp" "$CFG"
    echo "$CFG user update."

    curl -sSL "$URL_HELP" -o "$HELP_DIR/help.tar.gz"
    echo "niri help has been installed."
    tar -xzf "$HELP_DIR/help.tar.gz" -C "$HELP_DIR"
    echo "niri help has been extracted."
    rm -f "$HELP_DIR/help.tar.gz"
    echo "archive deleted"

    curl -sSL "$URL1" -o "$WALL_DIR/toki_in_space-0.3_overview.png"
    echo "wallpaper for overview installed"
    curl -sSL "$URL2" -o "$WALL_DIR/toki_in_space-blurred.png"
    echo "niri wallpaper have been installed."

    echo "niri is configured"
fi
exit 0
