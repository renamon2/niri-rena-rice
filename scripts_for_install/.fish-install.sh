#!/bin/bash

if command -v xbps-install >/dev/null 2>&1; then
    echo "xbps-install found"
    PKG_MANAGER="xbps-install"
else
    echo "xbps-install not found. Exiting..."
    exit 1
fi

ask_yes_no() {
    read -t 5 -p "$1 (Y/n) [Auto-yes in 5s]: " yn
    if [ -z "$yn" ]; then
        echo -e "\nTimeout or Enter pressed! Defaulting to: YES"
        return 0
    fi
    case $yn in
        [YyДд]* | [Yy][Ee][Ss] | [Дд][Аа] | "yep" | "yeah" | "sure" ) 
            return 0
            ;;
        [NnНн]* | [Nn][Oo] | [Нн][Ее][Тт] | "nope" | "nay" ) 
            return 1
            ;;
        * ) 
            echo "Unknown response. Defaulting to: NO"
            return 1 
            ;;
    esac
}

URL="https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"
DIST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fish"

if command -v fish >/dev/null 2>&1; then
    echo "fish shell is already installed."
else
    echo "Installing fish shell..."
    sudo "$PKG_MANAGER" -Sy fish
    echo "fish shell installed."
fi
#проверка существования директории шелла фиш
if [ ! -d "$DIST_DIR" ]; then
    mkdir -p "$DIST_DIR"
    echo "Created fish config directory: $DIST_DIR"
    touch "$DIST_DIR/config.fish"
    echo "Created fish config file: $DIST_DIR/config.fish"
fi

if [ ! -f "$DIST_DIR/config.fish" ]; then
    echo "Fish config file does not exist: $DIST_DIR/config.fish"
    touch "$DIST_DIR/config.fish"
    echo "Created fish config file: $DIST_DIR/config.fish"
else
    echo "backup: $DIST_DIR/config.fish"
    mv "$DIST_DIR/config.fish" "$DIST_DIR/config.fish.bak"
    echo "backup created: $DIST_DIR/config.fish.bak"
    touch "$DIST_DIR/config.fish"
    echo "created: $DIST_DIR/config.fish"
fi

echo "Installing fisher..."
fish -c "curl -sL $URL | source && fisher install jorgebucaran/fisher"
echo "Fisher installed successfully."

cat <<EOF > "$DIST_DIR/config.fish"
if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_greeting "!ты в терминале fish-shell!"

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
if status --is-login
    if test -S /run/seatd.sock
        set -gx LIBSEAT_BACKEND seatd
    elif test -d /run/elogind
        set -gx LIBSEAT_BACKEND elogind
    elif test -S /run/dbus/system_bus_socket
        set -gx LIBSEAT_BACKEND elogind
    else
        set -e LIBSEAT_BACKEND
    end
end
EOF