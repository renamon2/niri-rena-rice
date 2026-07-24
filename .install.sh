#!/bin/bash
# ask
ask_yes_no() {
    read -t 5 -p "$1 (Y/n) [Auto-yes in 5s]: " yn < /dev/tty
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

# pkg mng
if command -v xbps-install && grep -rq "vostoklinux.org" /etc/xbps.d/ 2>/dev/null || grep -rq "vostoklinux.org" /usr/share/xbps.d/ 2>/dev/null || grep -q "vostok" /etc/os-release 2>/dev/null; then
    PACKAGE="niri xdg-desktop-portal-wlr dolphin jq firefox octoxbps zed gwenview ark gucharmap xdg-desktop-portal-gtk qt6-wayland git curl qt5-wayland kitty Waybar fish-shell SwayNotificationCenter rofi"
    PKG_MANAGER="xbps-install -Suy"
    PACKAGES_TO_INSTALL=$PACKAGE_VOID
    echo "vostok linux repo found"
fi

if command -v niri > /dev/null 2>&1; then
    bash <(curl -f -sL https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/scripts_for_install/kitty-color.sh)
    echo "Kitty color scheme installed. From https://raw.githubusercontent.com/ttys3/oh-my-kitty and used my theme."
    bash <(curl -sSL https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/waybar/.install.sh)
    echo "Waybar configured"
    bash <(curl -sSL https://raw.githubusercontent.com/renamon2/kvantum-rena/refs/heads/master/.install.sh)
    echo "qt and gtk is configured"
    bash <(curl -sSL https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/swaync/.install.sh)
    echo "Notification is configured"
    bash <(curl -sSL https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/rofi/.install.sh)
    echo "rofi is configured"
    bash <(curl -sSL https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/scripts_for_install/.fish-install.sh)
    echo "fish is configured"
    bash <(curl -sSL https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/scripts_for_install/.install.sh)
    echo "niri is configured"
fi

exit 0
