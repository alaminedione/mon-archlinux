#!/usr/bin/env bash

## Applets : System Status

# Import Current Theme
source "$HOME"/.config/rofi/applets/shared/theme.bash
theme="$type/$style"

# Theme Elements
prompt=' System Status'
# affichage du date et heure
mesg="  $(date +'%d %b %Y - %H:%M')"

if [[ ("$theme" == *'type-1'*) || ("$theme" == *'type-3'*) || ("$theme" == *'type-5'*) ]]; then
    list_col='1'
    list_row='4'
elif [[ ("$theme" == *'type-2'*) || ("$theme" == *'type-4'*) ]]; then
    list_col='4'
    list_row='1'
fi

# Fonction icône batterie
get_battery_icon() {
    local percent=$1
    local status=$2

    if [[ "$status" == "Charging" ]]; then
        echo ""
    elif ((percent >= 90)); then
        echo ""
    elif ((percent >= 75)); then
        echo ""
    elif ((percent >= 50)); then
        echo ""
    elif ((percent >= 25)); then
        echo ""
    else
        echo ""
    fi
}

# Batterie
battery_path=$(ls /sys/class/power_supply/BAT*/capacity 2>/dev/null | head -1)
if [[ -n "$battery_path" ]]; then
    battery_percent=$(cat "$battery_path")
    battery_status=$(cat "${battery_path%/*}/status")
    battery_icon=$(get_battery_icon $battery_percent "$battery_status")
    battery_info="$battery_icon $battery_percent%"
else
    battery_info=" N/A"
fi

# Volume
volume_info=$(amixer get Master | awk -F'[][]' 'END{print $2}')
is_muted=$(amixer get Master | awk -F'[][]' 'END{print $4}')
if [[ "$is_muted" == "off" ]]; then
    volume_icon=""
else
    volume_icon=""
fi
volume_info="$volume_icon ${volume_info//%/}%"

# Luminosité
backlight=$(light -G | cut -d'.' -f1)
brightness_info=" ${backlight}%"

# WiFi avec iwconfig
wifi_info=$(iwconfig wlan0 2>/dev/null)
essid=$(echo "$wifi_info" | grep "ESSID" | cut -d'"' -f2)
signal=$(echo "$wifi_info" | grep "Signal level" | awk -F'=' '{print $3}' | awk '{print $1 }')

if [[ -n "$essid" && "$essid" != "off/any" ]]; then
    wifi_icon=""
    wifi_info="$wifi_icon $essid $signal"
else
    wifi_icon="睊"
    wifi_info="$wifi_icon"
fi

# Options Finales
options="$battery_info\n$volume_info\n$brightness_info\n$wifi_info"

# Configuration Rofi
rofi_cmd() {
    rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
        -theme-str 'textbox-prompt-colon {str: "";}' \
        -theme-str "element-text {font: \"JetBrains Mono Nerd Font 14\";}" \
        -dmenu \
        -p "$prompt" \
        -mesg "$mesg" \
        -markup-rows \
        -theme "${theme}"
}

# Affichage
echo -e "$options" | rofi_cmd
