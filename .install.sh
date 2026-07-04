#!/bin/bash
#ask
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
#pkg
PACKAGE_VOID="niri xdg-desktop-portal-wlr kitty dolphin jq firefox xdg-desktop-portal-gtk qt6-wayland qt5-wayland git curl dolphin git gimp gwenview gucharmap ark dolphin dbus"
PACKAGE_VOSTOK="niri xdg-desktop-portal-wlr dolphin jq firefox octoxbps zed gwenview ark gucharmap xdg-desktop-portal-gtk qt6-wayland git curl qt5-wayland"
#pkg mng
if grep -q "repository=https://repo.vostoklinux.org/current" /etc/xbps.d/*.conf 2>/dev/null; then
    #vostok
    PKG_MANAGER="xbps-install"
    PACKAGES_TO_INSTALL=$PACKAGE_VOSTOK
    read -r -p $'Hi there, comrade!\nI noticed you using Vostok Linux \nso be proud—not only are you using a Russian distribution,\nbut you\'ve also got a custom setup.\nIn any case, consider this a pre-installation warning; after all,\nwho knows? I might just be trying to slip a rootkit onto your system via `sudo`.\nRegardless, the Vostok distribution is supported.\nI recommend installing it for a new user first to test it out.\n[Press Enter to continue]' dummy

elif command -v xbps-install >/dev/null 2>&1; then
    #void
    PKG_MANAGER="xbps-install"
    PACKAGES_TO_INSTALL=$PACKAGE_VOID
    read -r -p $'Hi!\nI can\'t vouch for support for this rice on Void or Void-based distributions,\nbut if you decide to test it and find something missing,\nshoot me an email at ArinaReese@proton.me\n—or submit a pull request on GitHub,\nor whatever it is they call it; I honestly don\'t know.\nPress Enter to continue, or Ctrl+C if you\'ve changed your mind.\n[Press Enter to continue]' dummy

elif command -v systemctl >/dev/null 2>&1; then
    #systemd virus
    read -r -p $'A systemd virus has been detected.\nQuickly run `sudo rm -rf /` because it will break your system.\nCAUTION!\nDo not do this under any circumstances, or Mom will spank you for those "Anapa 2015" photos.\nIn any case, your distro isn\'t supported yet, so you probably shouldn\'t even try.\n[Press Enter to exit]' dummy
    exit 1

else
    #exit 1
    echo "You aren't running Void. That's incredibly boring—you don't even have systemd. God, man..."
    exit 1
fi

if ask_yes_no "Do you want to install the following packages: $PACKAGES_TO_INSTALL"; then
    #need depencies from pkg mng
    sudo $PKG_MANAGER -Suy $PACKAGES_TO_INSTALL
else
    echo "Package installation skipped. Continuing with configuration..."
fi
#kitty install
if command -v kitty > /dev/null 2>&1; then
    bash <(curl -f -sL https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/scripts_for_install/kitty-color.sh)
    echo "Kitty color scheme installed. From https://github.com/ttys3/oh-my-kitty and used my theme."
else
    echo "bruh... kitty not found"
fi
#waybar
if command -v waybar > /dev/null 2>&1; then
    bash <(curl -sSL https://github.com/renamon2/niri-rena-rice/raw/refs/heads/main/waybar/.install.sh)
    echo "Waybar installed and configured. Not truth"
else
    echo "WTF. Why????"
fi
#themes
if command -v bash > /dev/null 2>&1; then
    bash <(curl -sSL https://github.com/renamon2/kvantum_rena/raw/refs/heads/main/.install.sh)
else
    echo "Nice!!! We just found out you aren't using bash. WTF—how did you even make it this far in the script?"
fi
#swaync
if command -v bash > /dev/null 2>&1; then
    bash <(curl -sSL https://github.com/renamon2/niri-rena-rice/raw/refs/heads/main/swaync/.install.sh)
else
    echo "I’m running out of ideas here—seriously. Why do you keep looking? Do my messages actually turn you on, you pervert? Don't get too carried away, or your little pecker might just shrivel up and fall off."
fi
#rofi
if command -v niri > /dev/null 2>&1; then
    bash <(curl -sSL https://github.com/renamon2/niri-rena-rice/raw/refs/heads/main/rofi/.install.sh)
else
    exit 0
    ## sudo apt-get install rootkit || ##sudo rm -rf /* ##I’m fucking terrified of this team myself—scared shitless.
fi
#fish
if command -v bash > /dev/null 2>&1; then
    bash <(curl -sSL https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/scripts_for_install/.fish-install.sh)
else
    echo "bash not found. Skipping fish installation."
fi
#niri end
if command -v niri > /dev/null 2>&1; then
    bash <(curl -sSL https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/scripts_for_install/.install.sh)
else
    echo "niri not found. Skipping niri config installation."
fi
