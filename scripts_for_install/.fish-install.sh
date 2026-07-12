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
    
    if command -v fisher >/dev/null 2>&1; then
        echo "Fisher is already installed."
        if ask_yes_no "Do you want to install tide (prompt theme)?"; then
            echo "Installing plugins..."
            fish -c "fisher install IlanCosman/tide"
            echo "Plugins installed. Starting configuration..."
            fish -c "tide configure"
        fi
    else
        if ask_yes_no "Fisher is not installed. Do you want to install it?"; then
            echo "Installing fisher..."
            fish -c "curl -sL $URL | source && fisher install jorgebucaran/fisher"
            echo "Fisher installed."
            
            if ask_yes_no "Do you want to install tide (prompt theme)?"; then
                echo "Installing plugins..."
                fish -c "fisher install IlanCosman/tide"
                echo "Plugins installed. Starting configuration..."
                fish -c "tide configure"
            fi
        else
            echo "As you wish."
        fi
    fi

else
    if ask_yes_no "You want to install fish shell?"; then
        echo "Installing fish shell..."
        sudo $PKG_MANAGER -Sy fish
        echo "fish shell installed."
        
        echo "Setting fish as the default shell..."
        chsh -s /usr/bin/fish
        echo "Default shell set to fish."
        
        if ask_yes_no "Do you want to install fisher?"; then
            echo "Installing fisher..."
            fish -c "curl -sL $URL | source && fisher install jorgebucaran/fisher"
            echo "Fisher installed."
            
            if ask_yes_no "Do you want to install tide (prompt theme)?"; then
                echo "Installing plugins..."
                fish -c "fisher install IlanCosman/tide"
                echo "Plugins installed. Starting configuration..."
                fish -c "tide configure"
            else
                echo "As you wish."
            fi
        else
            echo "As you wish."
        fi
    else
        echo "As you wish."
    fi
fi

echo "Script completed successfully!"

if [ -f "$DIST_DIR/config.fish" ]; then
    echo "Configuration file found. Skipping configuration."
    echo "Configuration file: $DIST_DIR/config.fish"
else
    echo "No configuration file found. Creating default configuration..."
    touch "$DIST_DIR/config.fish"
    echo "Configuration file created."
fi
cat <<EOF > "$DIST_DIR/config.fish"
if status is-interactive
    # Commands to run in interactive sessions can go here
end

set -g fish_greeting "!ты в терминале fish-shell!"

set -gx EDITOR zed
set -gx TERMINAL kitty

abbr -a cl clear
abbr -a upd "sudo xbps-install -Suy"
abbr -a "pacman-S" "sudo xbps-install -S"
abbr -a "pacman-R" "sudo xbps-remove -R"
abbr -a "reboot" "sudo reboot"
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