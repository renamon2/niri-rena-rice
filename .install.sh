#!/bin/bash
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
# BACKUP QUESTION
BACKUP=no
if ask_yes_no; then
    BACKUP=yes
else
    BACKUP=no
fi
REQUIRED_APPS=(
    "niri" "btop" "xdg-desktop-portal-wlr" "awww" "dolphin" "jq"
    "wireshark-qt" "firefox" "octoxbps" "zed" "gwenview" "ark"
    "gucharmap" "xdg-desktop-portal-gtk" "qt6-wayland" "git"
    "NetworkManager" "pavucontrol" "nerd-fonts-symbols-ttf"
    "font-firacode" "curl" "qt5-wayland" "kitty" "Waybar"
    "fish" "SwayNotificationCenter" "rofi"
)
MISSING_APPS=($(type -p "${REQUIRED_APPS[@]}" 2>&1 | awk '/not found/ {print $NF}' | tr -d "«»'\"\`"))
# PACKAGE MANAGER
if [ ${#MISSING_APPS[@]} -gt 0 ]; then
    echo "⚠️ Обнаружены отсутствующие пакеты: ${MISSING_APPS[*]}"
    if command -v xbps-install && grep -rq "vostoklinux.org" /etc/xbps.d/ 2>/dev/null || grep -rq "vostoklinux.org" /usr/share/xbps.d/ 2>/dev/null || grep -q "vostok" /etc/os-release 2>/dev/null; then
        echo "vostok linux repo found"
        sudo xbps-install -Suy "${MISSING_APPS[@]}"
        echo "installed missing apps: ${MISSING_APPS[@]}"
    fi
fi
### KITTY ###
# VARIABLES
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/kitty"
REPO_URL="https://github.com/ttys3/oh-my-kitty.git"
# CREATE DESTINATION DIRECTORY
mkdir -p "$DEST_DIR"
# BACKUP CREATION
if [ "$BACKUP" = "yes" ] && [ -d "$DEST_DIR" ] && [ "$(ls -A "$DEST_DIR")" ]; then
    echo "Creating backup..."
    BACKUP_DIR="$HOME/.config/kitty_backup_$(date +%Y%m%d_%H%M%S)"
    mv "$DEST_DIR" "$BACKUP_DIR"
    echo "Backup moved to: $BACKUP_DIR"
fi
# GIT CLONE
git clone "$REPO_URL" "$DEST_DIR"
rm -rf "$DEST_DIR/.git" "$DEST_DIR/.gitignore"
echo "Files updated successfully!"
# CHANGES CONFIGURATION
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
# VARIABLES and CREATION DIRECTORY
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/waybar"
mkdir -p "$DEST_DIR"
# BACKUP
if [ "$BACKUP" = "yes" ] && [ -f "$DEST_DIR/config.jsonc" ]; then
    mv "$DEST_DIR/config.jsonc" "$DEST_DIR/config.jsonc.bak"
    mv "$DEST_DIR/style.css" "$DEST_DIR/style.css.bak"
    echo "Backup created: $DEST_DIR/style.css.bak and $DEST_DIR/config.jsonc.bak"
else
    echo "Existing config not found, skipping backup."
fi
# CREATION config.jsonc
touch "$DEST_DIR/config.jsonc"
cat <<EOF > "$DEST_DIR/config.jsonc"
/*=======================================================================
--------------------------------SETTINGS---------------------------------
=======================================================================*/
{
  "layer": "top",
  "position": "top",

  "blur": true,
  "modules-left": [
    "tray",
    "niri/window"
  ],
  "modules-center": [
    "clock#1",
    "clock#2"
  ],
  "modules-right": [
    "group/audio-drawer",
    "group/btop-drawer",
    "backlight",
    "niri/language",
    "bluetooth",
    "network",
    "group/power",
  ],
  /*=======================================================================
  ----------------------------------TRAY-----------------------------------
  =======================================================================*/
  "tray": {
    "icon-size": 25,
    "spacing": 10,
    "show-passive-items": true,
    "reverse-direction": true,
  },
  /*=======================================================================
  ----------------------------------WINDOW---------------------------------
  =======================================================================*/
  "niri/window": {
    "format": "{}",
    "max-length": 60,
    "separate-outputs": false,
  },
  /*=======================================================================
  --------------------------------DATE AND TIME----------------------------
  =======================================================================*/
  "clock#1": {
    "type": "clock",
    "format": " {:%H:%M}",
    "tooltip-format": "{tz_list}",
    "on-click": "none",
    "tooltip": true,
    "timezones": [
        "",
        "Europe/Moscow",
        "Europe/Paris",
        "America/New_York",
        "Asia/Tokyo"
      ],
      "actions": {
          "on-scroll-up": "tz_up",
          "on-scroll-down": "tz_down"
      }
  },
  "clock#2": {
    "type": "clock",
    "format": " {0:%d.%m.%Y}",
    "on-click": "none",
    "tooltip": true,
    "tooltip-format": "<tt><small>{calendar}</small></tt>",
  },
/*=======================================================================
------------------------------------SOUND--------------------------------
=======================================================================*/
  "group/audio-drawer": {
    "type": "hbox",
    "orientation": "horizontal",
    "drawer": {
      "transition-duration": 400,
      "children-class": "audio-extended",
      "transition-left-to-right": true,
    },
    "modules": ["pulseaudio#output", "pulseaudio#input"],
  },
  "pulseaudio#output": {
    "format": "{icon} {volume}%",
    "format-icons": {
      "headphone": "󰋋",
      "default": ["󰕿", "󰖀", "󰕾"],
    },
    "format-muted": "󰖁 {volume}%",
    "on-click": "pavucontrol",
    "tooltip-format": "Output: {desc}\nЛКМ: pavucontrol",
  },
  "pulseaudio#input": {
    "format": "{format_source}",
    "format-source": " {volume}%",
    "format-source-muted": " {volume}%",
    "tooltip-format": "Microphone: {desc}",
    "tooltip-format-muted": "Muted {desc}",
    "on-click": "pactl set-source-mute @DEFAULT_SOURCE@ toggle",
    "on-scroll-up": "pactl set-source-volume @DEFAULT_SOURCE@ +5%",
    "on-scroll-down": "pactl set-source-volume @DEFAULT_SOURCE@ -5%",
    "scroll-step": 1,
  },
/*===========================================================================
------------------------------------BTOP-------------------------------------
===========================================================================*/
"group/btop-drawer": {
    "orientation": "horizontal",
    "drawer": {
      "transition-duration": 500,
      "children-class": "btop-extended",
      "transition-left-to-right": false,
    },
    "modules": [
      "custom/btop-trigger",
      "temperature",
      "memory",
      "cpu",
      "battery",
    ],
  },

  "custom/btop-trigger": {
    "format": "btop",
    "on-click": "kitty -e btop",
    "tooltip-format": "ЛКМ: btop++",
  },
/*===========================================================================
---------------------------------BATTERY-------------------------------------
===========================================================================*/
  "battery": {
    "states": {
      "good": 95,
      "warning": 30,
      "critical": 15,
    },
    "interval": 30,
    "format": "{capacity}% {icon}",
    "format-full": "{capacity}% {icon}",
    "format-charging": "{capacity}% 󰂄",
    "format-plugged": "{capacity}% ",
    "format-alt": "{time} 󱧦",
    // "format-good": "󱈑",
    "format-full": "full 󱟢",
    "format-icons": {
      "charging": ["󰢜", "󰂆", "󰂇", "󰂈", "󰢝", "󰂉", "󰢞", "󰢞", "󰂊", "󰂅"],
      "default": ["󰁺", "󰁻", "󰁼", "󰁽", "󰁾", "󰁿", "󰂀", "󰂁", "󰂂", "󰁹"],
    },
  },
  "battery#bat2": {
    "bat": "BAT2",
  },

/*===========================================================================
-----------------------------------CPU---------------------------------------
===========================================================================*/
  "cpu": {
      "interval": 2,
      "states": {
        "warning": 70,
        "critical": 90
      },
      "format": "{icon} {usage}%",
      "format-alt": "{avg_frequency} GHz 󰻠",
      "format-icons": [
        "",
        "󰈸",
        "󱗗"
      ],
      "tooltip-format": "<tt>Total Usage: {usage}%\nLoad Avg:    {load}\n\nAvg Freq:    {avg_frequency} GHz\nMax Freq:    {max_frequency} GHz\nMin Freq:    {min_frequency} GHz</tt>"
    },
/*===========================================================================
-----------------------------------MEMORY------------------------------------
===========================================================================*/
  "memory": {
    "interval": 3,
    "states": {
      "warning": 80,
      "critical": 95
    },
    "format": " {percentage}%",
    "format-alt": " {used:.1f}G/{total:.1f}G",
    "tooltip-format": "    === RAM ===\nUsage:      {percentage}%\nUsed:       {used:.1f} GiB\nAvailable:  {avail:.1f} GiB\nTotal:      {total:.1f} GiB\n\n   === SWAP ===\nUsage:      {swapPercentage}%\nUsed:       {swapUsed:.1f} GiB\nAvailable:  {swapAvail:.1f} GiB\nTotal:      {swapTotal:.1f} GiB"
  },

/*===========================================================================
-----------------------------------TEMPERATURE----------------------------------
===========================================================================*/
  "temperature": {
    "interval": 2,
    "critical-threshold": 80,
    "format": "{icon} {temperatureC}°C",
    "format-critical": "{icon} {temperatureC}°C ",
    "format-icons": ["", "", "", "", ""],
    "tooltip-format": "Celsius:    {temperatureC}°C\nFahrenheit: {temperatureF}°F"
  },

/*===========================================================================
-----------------------------------BACKLIGHT---------------------------------
===========================================================================*/
  "backlight": {
    "scroll-step": 5,
    "format": "{icon} {percent}%",
    "format-icons": ["󱩎", "󱩏", "󱩐", "󱩑", "󱩒", "󱩓", "󱩔", "󱩕", "󱩖", "󰛨"],
    "format-alt": "󰛨 Brightness: {percent}%"
  },

/*===========================================================================
-----------------------------------LANGUAGE----------------------------------
===========================================================================*/
  "niri/language": {
      "format": "󰌌 {}",
      "format-en": "EN",
      "format-us": "US",
      "format-ru": "RU",
      "format-uk": "UA",
      "format-by": "BY",
      "format-kz": "KZ",
      "format-de": "DE",
      "format-fr": "FR",
      "format-es": "ES",
      "format-it": "IT",
      "format-pl": "PL",
  },
/*===========================================================================
-----------------------------------NETWORK------------------------------------
===========================================================================*/
  "network": {
    "interval": 2,
    "format-wifi": "{icon} {signalStrength}%",
    "format-ethernet": "󰈁 Wired",
    "format-disconnected": "󰈂 Disconnected",
    "format-icons": [
      "󰤯",
      "󰤟",
      "󰤢",
      "󰤥",
      "󰤨"
    ],
    "tooltip-format-wifi": "=== Wi-Fi Network ===\nSSID:       {essid}\nSignal:     {signalStrength}%\nInterface:  {ifname}\nIP Address: {ipaddr}\n\nTraffic:    ↓ {bandwidthDownBytes}  ↑ {bandwidthUpBytes}\n\n[L-Click] Network Menu  [M-Click] Wireshark  [R-Click] Zapret",
    "tooltip-format-ethernet": "=== Ethernet Connection ===\nInterface:  {ifname}\nIP Address: {ipaddr}\n\nTraffic:    ↓ {bandwidthDownBytes}  ↑ {bandwidthUpBytes}\n\n[L-Click] Network Menu  [M-Click] Wireshark  [R-Click] Zapret",
    "tooltip-format-disconnected": "=== Network ===\nStatus: Disconnected",
    "on-click": "kitty -e nmtui",
    "on-click-middle": "exec wireshark",
    "on-click-right": "kitty -e zapret"
  },
/*===========================================================================
-----------------------------------POWER-------------------------------------
===========================================================================*/
  "group/power": {
    "orientation": "horizontal",
    "drawer": {
      "transition-duration": 500,
      "children-class": "btop-extended",
      "transition-left-to-right": false,
    },
    "modules": ["custom/power", "custom/reboot", "custom/quit"],
  },

  "custom/power": {
    "format": "󰐥",
    "on-click": "poweroff",
    "tooltip": false,
  },

  "custom/reboot": {
    "format": " 󰦛 ",
    "on-click": "reboot",
    "tooltip": false,
  },

  "custom/quit": {
    "format": "  ",
    "on-click": "swaylock",
    "tooltip": false,
  },
/*===========================================================================
-----------------------------------BLUETOOTH---------------------------------
===========================================================================*/
  "bluetooth": {
    "format": "󰂯",
    "format-disabled": "󰂲",
    "format-connected": "󰂱 {device_alias}",
    "format-connected-battery": "󰂱 {device_alias} 󰥉 {device_battery_percentage}%",

    "tooltip-format": "Контроллер: {controller_alias}\n{num_connections} подключено",
    "tooltip-format-connected": "Контроллер: {controller_alias}\n\nПодключено:\n{device_enumerate}",
    "tooltip-format-enumerate-connected": "• {device_alias}\t{device_address}",
    "tooltip-format-enumerate-connected-battery": "• {device_alias}\t{device_address}\t🔋{device_battery_percentage}%",

    "on-click": "blueman-manager",
  },
}
EOF
echo "config.jsonc created"
# CREATION style.css
touch "$DEST_DIR/style.css"
cat <<EOF > "$DEST_DIR/style.css"
* {
    font-family:
        "DejaVu Sans Mono", "Symbols Nerd Font", "FiraCode Nerd Font",
        "JetBrainsMono Nerd Font", monospace;
    font-size: 1rem;
    font-weight: bold;
    border: none;
    border-radius: 0;
}
window#waybar {
    background-color: rgba(24, 34, 46, 0.8); /* Base */
    border-radius: 0px;
    color: #70437e;
}
window > box {
    min-height: 2.0rem;
}
#bluetooth,
#power,
#custom-quit,
#custom-reboot,
#tray,
#window,
#clock.module.1,
#clock.module.2,
#pulseaudio,
#battery,
#cpu,
#memory,
#temperature,
#backlight,
#language,
#network,
#custom-btop-trigger,
#custom-power {
    padding: 0rem 1.1rem;
    background-color: rgba(44, 34, 68, 0.75);
    color: #70437e;
}
#window:hover
#bluetooth:hover,
#clock.module.2:hover,
#clock.module.1:hover,
#window:hover,
#clock.module.2:hover,
#custom-quit:hover,
#custom-reboot:hover,
#battery:hover,
#cpu:hover,
#memory:hover,
#pulseaudio.output:hover,
#temperature:hover,
#backlight:hover,
#language:hover,
#network:hover,
#custom-power:hover,
#tray:hover,
#clock.module.1:hover,
#clock.module.2:hover,
#custom-btop-trigger:hover,
#pulseaudio:hover {
    border-radius: 0.5rem;
    background-color: #c372ac ;
    color: #373f90;
}
tooltip {
    background-color: #18222e;
    border: 1px solid #373f90;
    border-radius: 0.5rem;
    padding: 8px;
    opacity: 0.8;
}
tooltip label {
    color: #373f90;
    font-family: "DejaVu Sans Mono", "Symbols Nerd Font", monospace;
}
#battery.critical,
#temperature.critical {
    background-color: #c373ac;
    color: #f3f7f6;
}
#clock.module.1,
#pulseaudio.output {
    border-radius: 8px 0px 0px 8px;
}
#clock.module.2,
#window {
    border-radius: 0rem 0.5rem 0.5rem 0rem;
}
EOF
echo "style.css created"
echo "Waybar configured"
### THEMES ###
if ask_yes_no "Do you want to install Kvantum themes?"; then
    bash <(curl -sSL https://raw.githubusercontent.com/renamon2/kvantum-rena/refs/heads/master/.install.sh)
    echo "qt and gtk is configured"
else
    echo "Skipping Kvantum themes installation."
fi
### NOTIFICATION (SWAYNC) ###
# VARIABLES
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/swaync"
REPO1_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/swaync/config.json"
REPO2_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/swaync/style.css"
# DIRECTORY CREATION
mkdir -p "$DEST_DIR"
if [ "$BACKUP" = "yes" ] && [ -f "$DEST_DIR/config.json" ]; then
    mv "$DEST_DIR/config.json" "$DEST_DIR/config.json.bak"
    mv "$DEST_DIR/style.css" "$DEST_DIR/style.css.bak"
    echo "Backup created: $DEST_DIR/config.json.bak and $DEST_DIR/style.css.bak"
else
    echo "Existing config not found, skipping backup."
fi
# FILE DOWNLOAD
touch "$DEST_DIR/config.json"
cat << 'EOF' > "$DEST_DIR/config.json"
{
  "positionX": "right",
  "positionY": "top",
  "layer": "overlay",
  "control-center-positionX": "right",
  "control-center-positionY": "top",
  "control-center-margin-top": 10,
  "control-center-margin-bottom": 10,
  "control-center-margin-right": 10,
  "control-center-width": 450,
  "fit-to-screen": false,
  "notification-window-width": 400,
  "keyboard-shortcuts": true,
  "image-visibility": "when-available",
  "transition-time": 250,
  "hide-on-clear": true,
  "hide-on-action": true,
  "script-fail-notify": true,
  "notification-2fa-action": true,
  "notification-inline-replies": true,
  "timeout": 10,
  "timeout-low": 5,
  "timeout-critical": 0,
  "widgets": [
    "title",
    "dnd",
    "mpris",
    "volume",
    "backlight",
    "notifications"
  ],
  "widget-config": {
    "title": {
      "text": "Уведомления",
      "clear-all-button": true,
      "button-text": "Очистить"
    },
    "dnd": {
      "text": "Не беспокоить"
    },
    "mpris": {
      "show-album-art": "always",
      "autohide": true,
      "loop-carousel": true
    },
    "volume": {
      "label": "Громкость",
      "show-per-app": true,
      "show-per-app-icon": true,
      "expand-per-app": false,
      "expand-button-label": "▼",
      "collapse-button-label": "▲"
    },
    "backlight": {
      "label": "Яркость"
    }
  },
  "scripts": {
    "ayugram-focus": {
      "exec": "bash -c 'id=$(niri msg -j windows | jq -r \".[] | select(.app_id == \\\"com.ayugram.desktop\\\") | .id\" | head -n1); [ -n \"$id\" ] && niri msg action focus-window --id \"$id\"'",
      "app-name": "AyuGram Desktop",
      "run-on": "action"
    },
    "firefox-focus": {
      "exec": "bash -c 'id=$(niri msg -j windows | jq -r \".[] | select(.app_id == \\\"Firefox\\\") | .id\" | head -n1); [ -n \"$id\" ] && niri msg action focus-window --id \"$id\"'",
      "app-name": "Firefox",
      "run-on": "action"
    },
    "dolphin-focus": {
      "exec": "bash -c 'id=$(niri msg -j windows | jq -r \".[] | select(.app_id == \\\"org.kde.dolphin\\\") | .id\" | head -n1); [ -n \"$id\" ] && niri msg action focus-window --id \"$id\"'",
      "app-name": "Dolphin",
      "run-on": "action"
    },
    "zed-focus": {
      "exec": "bash -c 'id=$(niri msg -j windows | jq -r \".[] | select(.app_id == \\\"dev.zed.Zed\\\") | .id\" | head -n1); [ -n \"$id\" ] && niri msg action focus-window --id \"$id\"'",
      "app-name": "Zed",
      "run-on": "action"
    },
    "wezterm-focus": {
      "exec": "bash -c 'id=$(niri msg -j windows | jq -r \".[] | select(.app_id == \\\"org.wezfurlong.wezterm\\\") | .id\" | head -n1); [ -n \"$id\" ] && niri msg action focus-window --id \"$id\"'",
      "app-name": "WezTerm",
      "run-on": "action"
    },
    "octoxbps-focus": {
      "exec": "bash -c 'id=$(niri msg -j windows | jq -r \".[] | select(.app_id == \\\"octoxbps\\\") | .id\" | head -n1); [ -n \"$id\" ] && niri msg action focus-window --id \"$id\"'",
      "app-name": "OctoXBPS",
      "run-on": "action"
    },
    "telegram-focus": {
      "exec": "niri msg action focus-window --app-id org.telegram.desktop",
      "app-name": "org.telegram.desktop",
      "run-on": "action"
    }
  }
}
EOF
touch "$DEST_DIR/style.css"
cat << 'EOF' > "$DEST_DIR/style.css"
/*=======================================================================
--------------------------------CONFIG-----------------------------------
=======================================================================*/
*{
    font-family: "Fira Code Light", monospace;
    font-size: 1rem;
}
.notification {
    background-color: rgba(24,34, 46, 0.4);
    color: #2c2244;
    border: 0.1rem solid rgba(44, 34, 68, 0.2);
    border-radius: 0.5rem;
    margin: 0.8rem;
    padding: 0.8rem;
}
.notification-icon {
    margin-right: 1.1rem;
    padding: 0.1rem;
    min-width: 3.5rem;
    min-height: 3.5rem;
}
.notification-icon image {
    border-radius: 0.3rem;
}
.notification-progress {
    background-color: rgba(44, 34, 68, 0.2);
}
/*=======================================================================
----------------------------BOUNCE ANIMATION-----------------------------
=======================================================================*/
@keyframes bounceIn {
    0% {
        opacity: 0;
        transform: scale(0.3) translateX(200px);
    }
    50% {
        opacity: 0.8;
        transform: scale(1.08) translateX(-20px);
    }
    70% {
        transform: scale(0.97) translateX(10px);
    }
    100% {
        opacity: 1;
        transform: scale(1) translateX(0);
    }
}
.widget-notifications {
    animation: bounceIn 0.42s cubic-bezier(0.175, 0.885, 0.32, 1.275) forwards;
}
EOF
echo "Notification is configured"
### DMENU (ROFI) ###
# VARIABLES
DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/rofi"
REPO_URL="https://raw.githubusercontent.com/renamon2/niri-rena-rice/refs/heads/main/rofi/config.rasi"
# CREATE DIRECTORY
mkdir -p "$DEST_DIR"
# BACKUP
if [ "$BACKUP" = "yes" ] && [ -f "$DEST_DIR/config.rasi" ]; then
    mv "$DEST_DIR/config.rasi" "$DEST_DIR/config.rasi.bak"
    echo "Backup created: $DEST_DIR/config.rasi.bak"
else
    echo "Existing config not found, skipping backup."
fi
# DOWNLOAD ROFI CONFIG
touch "$DEST_DIR/config.rasi"
cat << 'EOF' > "$DEST_DIR/config.rasi"
/*=======================================================================
--------------------------------CONFIG-----------------------------------
=======================================================================*/
configuration {
    modes: [ drun, filebrowser, run ];
    show-icons: true;
    drun-display-format: "{name}";
    disable-history: false;
    filebrowser {
        directory: "$HOME";
        sorting-method: "name";
    }
}
/*=======================================================================
--------------------------------COLORS-----------------------------------
=======================================================================*/
* {
    font: "DejaVu Sans Mono", "Symbols Nerd Font", "FiraCode Nerd Font", "JetBrainsMono Nerd Font mono 14";
    text: #373f90ff;
    subtle: #70437eff;
    base: #18222ecc;
    overlay: #2c2244cc;
    accent: #c372accc;
    rad: 8px;
}
/*=======================================================================
--------------------------------WINDOW-----------------------------------
=======================================================================*/
window {
    background-color: @base;
    border:           2px solid;
    border-color:     @overlay;
    border-radius:    @rad;
    width:            700px;
    padding:          10px;
    location:         center;
    anchor:           center;
}
mainbox {
    background-color: transparent;
    children: [ inputbar, listview ];
    spacing: 15px;
}
/*=======================================================================
------------------------------INPUTBAR-----------------------------------
=======================================================================*/
inputbar {
    background-color: @border-color-custom;
    border-radius:    @rad;
    padding:          10px 10px;
    children:         [ prompt, entry ];
    spacing:          10px;
}
prompt {
    background-color: transparent;
    text-color: @subtle;
}
entry {
    background-color: transparent;
    placeholder: "Search applications or files...";
    placeholder-color: @subtle;
    text-color: @text;
}
/*=======================================================================
------------------------------LISTVIEW-----------------------------------
=======================================================================*/
listview {
    layout:        vertical;
    lines:         8;
    columns:       2;
    spacing:       10px;
    fixed-height:  true;
    scrollbar:     false;
    background-color: transparent;
}
/*=======================================================================
-------------------------------ELEMENT-----------------------------------
=======================================================================*/
element {
    orientation:      horizontal;
    padding:          10px 10px;
    border-radius:    @rad;
    spacing:          10px;
    cursor:           pointer;
    background:       #ffccffcc;
}
element normal.normal,
element alternate.normal {
    background-color: @overlay;
    text-color:       @subtle;
}
element selected.normal {
    background-color: @accent;
    text-color:       @text;
}
/*=======================================================================
------------------------------ELEMENT ICON-------------------------------
=======================================================================*/
element-icon {
    size:             36px;
    background-color: transparent;
    vertical-align:   0.5;
}
element-text {
    background-color: transparent;
    text-color:       inherit;
    font:             inherit;
    vertical-align:   0.5;
}
EOF
echo "rofi is configured"
### SHELL (FISH) ###
# VARIABLES
URL="https://raw.githubusercontent.com/jorgebucaran/fisher/main/functions/fisher.fish"
DIST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/fish"
# CREATE DIRECTORY
mkdir -p "$DIST_DIR"
echo "make directory $DIST_DIR"
# INSTALL FISHER
if [ ! -a "$DIST_DIR/completions/fisher.fish" ]; then
    echo "Installing fisher..."
    fish -c "curl -sL $URL | source && fisher install jorgebucaran/fisher"
    echo "Fisher installed successfully."
fi
# CONFIGURE FISH
touch "$DIST_DIR/config.fish"
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
URL_HELP="https://raw.githubusercontent.com/renamon2/niri-rena-rice/main/help.tar.gz"
mkdir -p "$DEST_DIR"
mkdir -p "$HELP_DIR"
mkdir -p "$WALL_DIR"
if [ "$BACKUP" = "yes" ] && [ -f "$CFG" ]; then
    mv "$CFG" "$CFG.bak"
    echo "niri config.kdl has been backed up to $CFG.bak."
fi
touch "$CFG"
cat << 'EOF' > "$CFG"
/*=======================================================================
--------------------------------environment------------------------------
=======================================================================*/
environment {
    XMODIFIERS "@im=none"
    FONTCONFIG_FONT_RENDER_STYLE "hintslight"
    QT_QPA_PLATFORM "wayland;xcb"
    QT_QPA_PLATFORMTHEME "qt6ct"
    QT_COLOR_SCHEME "dark"
    QT_STYLE_OVERRIDE "kvantum"
    QT_CURSORS_SIZE "24"
    XCURSOR_PATH "/home/user/.local/share/icons"
    XCURSOR_THEME "Kitty_Cursors"
    //XCURSOR_SIZE "24"
    GDK_BACKEND "wayland,x11"
    MOZ_ENABLE_WAYLAND "1"
    SDL_VIDEODRIVER "wayland,x11"
    ELECTRON_OZONE_PLATFORM_HINT "wayland"
    _JAVA_AWT_WM_NONREPARENTING "1"
    GTK_THEME "rose-pine-gtk"
    XDG_CURRENT_DESKTOP "niri:wlroots"
    XDG_SESSION_TYPE "wayland"
    XDG_DATA_HOME "/home/user/.local/share"
    XDG_STATE_HOME "/home/user/.local/state"
    XDG_CONFIG_HOME "/home/user/.config"
    XDG_DATA_DIRS "/home/user/.local/share:/usr/local/share:/usr/share:/var/lib/flatpak/exports/share:/home/user/.local/share/flatpak/exports/share"
    __fish_config_dir "home/user/.config/fish"
    CLUTTER_BACKEND "wayland"
}
/*=======================================================================
-----------------------------------input---------------------------------
=======================================================================*/
input {
    keyboard {
        xkb {
            layout "us,ru"
            options "grp:caps_toggle,compose:ralt,ctrl:nocaps"
        }
    repeat-delay 600
    repeat-rate 35
    track-layout "global"
    numlock
    }
    touchpad {
        // off
        tap
        dwt
        dwtp
        drag false
        drag-lock
        // natural-scroll
        accel-speed 0.5
        accel-profile "adaptive"
        scroll-factor 0.7
        // scroll-factor vertical=1.0 horizontal=-2.0
        scroll-method "edge"
        // scroll-button 273
        // scroll-button-lock
        // tap-button-map "left-middle-right"
        // click-method "clickfinger"
        // left-handed
        disabled-on-external-mouse
        // middle-emulation
    }
    mouse {
        // off
        // natural-scroll
        accel-speed 0.2
        accel-profile "adaptive"
        // scroll-method "no-scroll"
        // scroll-button 273
        // scroll-button-lock
        // left-handed
        middle-emulation
    }
    trackpoint {
        // off
        // natural-scroll
        accel-speed 0.2
        accel-profile "adaptive"
        // scroll-method "on-button-down"
        // scroll-button 273
        // scroll-button-lock
        middle-emulation
    }
    tablet {
        // off
        // map-to-output "eDP-1"
        // map-to-focused-output
        // map-to-focused-window
        // left-handed
        // calibration-matrix 1.0 0.0 0.0 0.0 1.0 0.0
    }
    touch {
        // off
        // map-to-output "eDP-1"
        // calibration-matrix 1.0 0.0 0.0 0.0 1.0 0.0
    }
    // disable-power-key-handling
    warp-mouse-to-focus
    focus-follows-mouse max-scroll-amount="0%"
    workspace-auto-back-and-forth
    // mod-key "Super"
    // mod-key-nested "Alt"
}
/*=======================================================================
---------------------------------cursor----------------------------------
=======================================================================*/
cursor {
    xcursor-theme "Kitty_Cursors"
    xcursor-size 24
}
/*=======================================================================
---------------------------------monitor---------------------------------
=======================================================================*/
/*output "eDP-1" {
    // off
    mode "preffered@hz"
    scale scale
    transform "normal"
    position x=0 y=0
    variable-refresh-rate
    focus-at-startup
    // backdrop-color "#66003366"
    // max-bpc 8
    hot-corners {
        // off
        top-left
        // top-right
        // bottom-left
        // bottom-right
    }
}*/
/*=======================================================================
----------------------------------layout---------------------------------
=======================================================================*/
layout {
    gaps 14
    center-focused-column "on-overflow"
    preset-column-widths {
        proportion 0.25
        proportion 0.5
        proportion 0.75
        // fixed 1920
    }
    preset-window-heights {
        proportion 0.33333
        proportion 0.5
        proportion 0.66667
    }
    default-column-width { proportion 0.5; }
    focus-ring {
        // off
        width 2
        active-color "#2c2244"
        inactive-color "#18222e"
        urgent-color "#c372ac"
        // active-gradient from="#80c8ff" to="#c7ff7f" angle=45
        // inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
        // urgent-gradient from="#800" to="#a33" angle=45
    }
    border {
        // off
        width 2
        active-color "#2c2244"
        inactive-color "#18222e"
        urgent-color "#c372ac"
        // active-gradient from="#ff3366" to="#ff66cc" angle=45 relative-to="workspace-view" in="oklch longer hue"
        // inactive-gradient from="#ff99cc" to="#ff99ff" angle=45 relative-to="workspace-view"
    }
    shadow {
        on
	// off
        softness 15
        spread 5
        offset x=0 y=5
        color "#70437e33"
        inactive-color "#000000cc"
    }
    tab-indicator {
        // off
        on
        // hide-when-single-tab
        // place-within-column
        // gap 5
        width 4
        // length total-proportion=1.0
        position "right"
        // gaps-between-tabs 2
        corner-radius 8
        active-color "#2c2244"
        inactive-color "#18222e"
        urgent-color "#c372ac"
        // active-gradient from="#80c8ff" to="#bbddff" angle=45
        // inactive-gradient from="#505050" to="#808080" angle=45 relative-to="workspace-view"
        // urgent-gradient from="#800" to="#a33" angle=45
    }
    insert-hint {
        // off
        on
        color "#c372ac"
        // gradient from="#ffbb6680" to="#ffc88080" angle=45 relative-to="workspace-view"
    }
    struts {
        // left 64
        // right 64
        // top 64
        // bottom 64
    }
}
blur {
    // off
    passes 3
    offset 3.0
    noise 0.3
    saturation 2.5
}
overview {
    zoom 0.7
    backdrop-color "#2c2244"
    workspace-shadow {
        // off
        softness 40
        spread 10
        offset x=0 y=10
        color "#70437e33"
    }
}
/*=======================================================================
------------------------------auto-startup-------------------------------
=======================================================================*/
	spawn-at-startup "pipewire"
	spawn-at-startup "wireplumber"
	spawn-at-startup "waybar"
    spawn-sh-at-startup "awww-daemon & sleep 0.3; awww img /home/arina/.config/niri/wallpaper/awww/toki_in_space-0.3_overview.png"
    spawn-sh-at-startup "awww-daemon -n -blur & sleep 0.3; awww img /home/arina/.config/niri/wallpaper/awww/toki_in_space-blurred.png --namespace blur"
	spawn-at-startup "swaync"
/*=======================================================================
----------------------------------another--------------------------------
=======================================================================*/
hotkey-overlay {
    // skip-at-startup
}
prefer-no-csd
screenshot-path "~/Pictures/Screenshots from %Y-%m-%d %H-%M-%S.png"
xwayland-satellite {
    // off
    path "xwayland-satellite"
}
clipboard {
    disable-primary
}
config-notification {
    // disable-failed
}
/*=======================================================================
---------------------------------animations------------------------------
=======================================================================*/
animations {
    slowdown 3.0
    horizontal-view-movement {
        spring stiffness=400 damping-ratio=0.60 epsilon=0.0001
    }
    window-movement {
        spring stiffness=500 damping-ratio=0.65 epsilon=0.0001
    }
    workspace-switch {
        spring stiffness=500 damping-ratio=0.65 epsilon=0.0001
    }
    window-open {
        spring stiffness=500 damping-ratio=0.62 epsilon=0.0001
    }
    window-close {
        spring stiffness=600 damping-ratio=0.70 epsilon=0.0001
    }
    window-resize {
        spring stiffness=500 damping-ratio=0.65 epsilon=0.0001
    }
    config-notification-open-close {
        spring stiffness=500 damping-ratio=0.65 epsilon=0.0001
    }
}
/*=======================================================================
-----------------------------Window Rules--------------------------------
=======================================================================*/
window-rule {
    opacity 0.95
}
window-rule {
    geometry-corner-radius 8
    clip-to-geometry true
}
window-rule {
    match is-floating=true
    border {
        width 1
        active-color "#c372ac"
        inactive-color "#18222e"
    }
}
window-rule {
    match app-id=r#"^gimp$"# title="^Запуск GIMP$"
    match app-id="^gimp$" title="^Добро пожаловать в GIMP"
    match app-id=r#"^gimp$"# title="^Starting GIMP$"
    match app-id="^gimp$" title="^Welcome to GIMP"
    match app-id=r#"^org.kde.gwenview$"#
    match app-id=r#"^Firefox$"# title="^Close Firefox$"
    match app-id="^Firefox$" title="^Picture-in-Picture$"
    match app-id="^Firefox$" title="^Картинка в картинке$"
    match app-id=r#"^gucharmap$"#
    match app-id=r#"^qt-sudo$"#
    open-floating true
    opacity 1.0
}
window-rule {
    match app-id=r#"^gimp$"# title="GNU Image Manipulation Program"
    open-maximized-to-edges true
    opacity 1.0
    tiled-state true
}
window-rule {
    match app-id=r#"^org.telegram.desktop$"#
    match app-id=r#"^com.ayugram.desktop$"#
    border {
        off
    }
    block-out-from "screen-capture"
}
window-rule {
    match app-id=r#"^kitty$"#
    default-column-width {}
}
window-rule {
    match app-id=r#"^org.kde.dolphin$"#
    opacity 0.975
    default-column-width { proportion 0.732; }
    popups {
        opacity 0.8
        geometry-corner-radius 5
        background-effect {
            xray true
            blur true
            noise 0.05
            saturation 3
        }
    }
}
window-rule {
    match app-id=r#"^org.kde.ark$"#
    default-column-width { proportion 0.407; }
    popups {
        opacity 0.8
        geometry-corner-radius 5
        background-effect {
            xray true
            blur true
            noise 0.05
            saturation 3
        }
    }
}
window-rule {
    match app-id=r#"^org.pulseaudio.pavucontrol$"#
    open-floating true
    default-column-width { fixed 660; }
    default-window-height { fixed 570; }
    default-floating-position x=15 y=10 relative-to="top-right"
}
window-rule {
    geometry-corner-radius 8
    clip-to-geometry true
}
window-rule {
    match is-floating=true
    border {
        width 1
        active-color "#c372ac"
        inactive-color "#18222e"
    }
}
/*=======================================================================
-----------------------------layer rules---------------------------------
=======================================================================*/
layer-rule {
    match namespace="^waybar$"
    background-effect {
	xray true
        blur true
        noise 0.05
        saturation 3
    }
}
layer-rule {
    match namespace="^awww-daemon-blur$"
    place-within-backdrop true
}
layer-rule {
    match namespace="^rofi$"
    background-effect {
        xray true
        blur true
        noise 0.05
        saturation 3
    }
}
/*=======================================================================
----------------------------Hotkey Bindkeys------------------------------
=======================================================================*/
binds {
    Mod+F1 { spawn-sh "firefox --new-window /home/$USER/.config/niri/help/help.html"; }
    Mod+T { spawn "kitty"; }
    Mod+D { spawn-sh "rofi -show drun || pkill rofi"; }
    Mod+P { spawn "swaylock"; }
    Mod+F { spawn "dolphin"; }
    Mod+X { spawn "gucharmap"; }
    Mod+Z repeat=false { toggle-overview; }
    Mod+Q repeat=false { close-window; }
    Mod+Left  { focus-column-left; }
    Mod+Down     { focus-window-or-workspace-down; }
    Mod+Up     { focus-window-or-workspace-up; }
    Mod+Right { focus-column-right; }
    Mod+H     { focus-column-left; }
    Mod+J     { focus-window-or-workspace-down; }
    Mod+K     { focus-window-or-workspace-up; }
    Mod+L     { focus-column-right; }
    Mod+Alt+Left  { move-column-left; }
    Mod+Alt+Right { move-column-right; }
    Mod+Alt+Up       { move-window-up-or-to-workspace-up; }
    Mod+Alt+Down     { move-window-down-or-to-workspace-down; }

    Mod+Alt+H     { move-column-left; }
    Mod+Alt+J     { move-column-right; }
    Mod+Alt+K     { move-window-up-or-to-workspace-up; }
    Mod+Alt+L     { move-window-down-or-to-workspace-down; }

    Mod+Tab { focus-workspace-previous; }

    Mod+Comma  { consume-or-expel-window-left; }
    Mod+Period { consume-or-expel-window-right; }

    Mod+R { switch-preset-column-width; }
    Mod+Minus { set-column-width "-10%"; }
    Mod+Equal { set-column-width "+10%"; }
    Mod+Shift+Minus { set-window-height "-10%"; }
    Mod+Shift+Equal { set-window-height "+10%"; }

    Mod+V  { toggle-window-floating; }
    Mod+Alt+V  { switch-focus-between-floating-and-tiling; }

    Mod+W  { toggle-column-tabbed-display; }

    Mod+Print  { screenshot-screen; }
    Print  { screenshot-window; }

    Mod+Escape  { toggle-keyboard-shortcuts-inhibit; }

    Mod+Shift+E  { quit; }

    Mod+Shift+P  { power-off-monitors; }

    XF86AudioRaiseVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1+ -l 1.0"; }
    XF86AudioLowerVolume allow-when-locked=true { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.1-"; }
    XF86AudioMute        allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"; }
    XF86AudioMicMute     allow-when-locked=true { spawn-sh "wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"; }

    XF86AudioPlay        allow-when-locked=true { spawn-sh "playerctl play-pause"; }
    XF86AudioStop        allow-when-locked=true { spawn-sh "playerctl stop"; }
    XF86AudioPrev        allow-when-locked=true { spawn-sh "playerctl previous"; }
    XF86AudioNext        allow-when-locked=true { spawn-sh "playerctl next"; }
    XF86MonBrightnessUp allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "10%-"; }
    XF86MonBrightnessDown allow-when-locked=true { spawn "brightnessctl" "--class=backlight" "set" "+10%"; }
    Mod+C           { center-column; }
    Mod+Alt+C       { center-visible-columns; }
    Mod+Shift+R { switch-preset-column-width-back; }
    Mod+Alt+Shift+R { switch-preset-window-height; }
    Mod+Alt+R { reset-window-height; }
    Mod+Shift+F { fullscreen-window; }
    Mod+Alt+F { expand-column-to-available-width; }
    Mod+TouchpadScrollDown { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02+"; }
    Mod+TouchpadScrollUp   { spawn-sh "wpctl set-volume @DEFAULT_AUDIO_SINK@ 0.02-"; }

    Mod+Shift+Left  { focus-monitor-left; }
    Mod+Shift+Down  { focus-monitor-down; }
    Mod+Shift+Up    { focus-monitor-up; }
    Mod+Shift+Right { focus-monitor-right; }
}
EOF
    echo "$CFG has been installed."
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

DEST_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/xdg-desktop-portal"
mkdir -p "$DEST_DIR"
touch "$DEST_DIR/portals.conf"
echo "$DEST_DIR created"
echo "$DEST_DIR/portals.conf created"
cat << 'EOF' > "$DEST_DIR/portals.conf"
[preferred]
default=wlr
EOF
echo "xdg-desktop-portal configured"

exit 0
