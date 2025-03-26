#!/usr/bin/env bash

## Applet : Theme Switcher

# Importer le thème actuel
source "$HOME/.config/rofi/applets/shared/theme.bash"
theme="$type/$style"

# Configuration
prompt='Changer de thème'
mesg="Sélectionnez un thème Catppuccin ou Gruvbox"

# Options de thème
themes=("latte" "frappe" "macchiato" "mocha" "gruvbox_light")

# Icônes associées (optionnelles)
icons=("" "" "" "" "")

# Paramètres d'affichage
if [[ ( "$theme" == *'type-1'* ) || ( "$theme" == *'type-3'* ) || ( "$theme" == *'type-5'* ) ]]; then
    list_col=1
    list_row=5
else
    list_col=5
    list_row=1
fi

# Vérifier si le thème utilise les icônes
layout=$(grep 'USE_ICON' "$theme" | cut -d'=' -f2)
if [[ "$layout" == 'NO' ]]; then
    options=("${themes[@]}")
else
    options=()
    for i in "${!themes[@]}"; do
        options+=("${icons[$i]} ${themes[$i]^}")
    done
fi

# Commande Rofi
rofi_cmd() {
    rofi -theme-str "listview {columns: $list_col; lines: $list_row;}" \
         -theme-str 'textbox-prompt-colon {str: "";}' \
         -theme-str "element-text {font: 'JetBrains Mono Nerd Font 12';}" \
         -dmenu -p "$prompt" -mesg "$mesg" -markup-rows \
         -theme "$theme"
}

# Exécuter la commande de changement de thème
run_cmd() {
    "$HOME/.local/bin/change-theme.sh" "$1"
}

# Afficher le menu et exécuter l'action
chosen=$(printf "%s\n" "${options[@]}" | rofi_cmd)

# Trouver l'index du thème choisi
selected_theme=""
for i in "${!options[@]}"; do
    if [[ "${options[$i]}" == "$chosen" ]]; then
        selected_theme="${themes[$i]}"
        break
    fi
done

# Appliquer le thème sélectionné
if [[ -n "$selected_theme" ]]; then
    run_cmd "$selected_theme"
fi
