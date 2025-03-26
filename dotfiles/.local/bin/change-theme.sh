#!/bin/bash
# Script de changement de thème système avec gestion améliorée des erreurs et configuration centralisée

# ------ Configuration centrale ------
declare -A CONFIG=(
    [ICON_THEME]="Vimix"
    [CURSOR_THEME]="WhiteSur-cursors"
    [CURSOR_SIZE]=28
    [FONT_NAME]="Roboto"
    [FONT_SIZE]=10
    [WALLPAPER_DIR]="$HOME/.config/bspwm/wallpaper"
)

# ------ Déclaration des thèmes ------
declare -A THEMES=(
    # GTK
    [latte / gtk]="gnome-professional-solid-40.1"
    [frappe / gtk]="gnome-professional-solid-40.1-dark"
    [macchiato / gtk]="gnome-professional-solid-40.1-dark"
    [mocha / gtk]="gnome-professional-solid-40.1-dark"
    [gruvbox_light / gtk]="Gruvbox-Light"

    # Kvantum
    [latte / kvantum]="KvGnome"
    [frappe / kvantum]="KvGnome"
    [macchiato / kvantum]="KvGnomeDark"
    [mocha / kvantum]="KvGnomeDark"
    [gruvbox_light / kvantum]="Gruvbox_Light_Blue"

    # Kitty
    [latte / kitty]="themes/latte.conf"
    [frappe / kitty]="themes/frappe.conf"
    [macchiato / kitty]="themes/macchiato.conf"
    [mocha / kitty]="themes/mocha.conf"
    [gruvbox_light / kitty]="themes/gruvbox-light.conf"

    # Alacritty
    [latte / alacritty]="catppuccin-latte.toml"
    [frappe / alacritty]="catppuccin-frappe.toml"
    [macchiato / alacritty]="catppuccin-macchiato.toml"
    [mocha / alacritty]="catppuccin-mocha.toml"
    [gruvbox_light / alacritty]="gruvbox-light.toml"

    # Foot
    [latte / foot]="catppuccin-latte.ini"
    [frappe / foot]="catppuccin-frappe.ini"
    [macchiato / foot]="catppuccin-macchiato.ini"
    [mocha / foot]="catppuccin-mocha.ini"
    [gruvbox_light / foot]="gruvbox-light.ini"

    # Bat
    [latte / bat]="Catppuccin Latte"
    [frappe / bat]="Catppuccin Frappe"
    [macchiato / bat]="Catppuccin Macchiato"
    [mocha / bat]="Catppuccin Mocha"
    [gruvbox_light / bat]="gruvbox-light"

    # Vim
    [latte / vim]="catppuccin_latte"
    [frappe / vim]="catppuccin_frappe"
    [macchiato / vim]="catppuccin_macchiato"
    [mocha / vim]="catppuccin_mocha"
    [gruvbox_light / vim]="gruvbox"

    # Neovim
    [latte / nvim]="catppuccin-latte"
    [frappe / nvim]="catppuccin-frappe"
    [macchiato / nvim]="catppuccin-macchiato"
    [mocha / nvim]="catppuccin-mocha"
    [gruvbox_light / nvim]="gruvbox-material"

    # Wallpaper
    [latte / wallpaper]="sean-o-riordan.jpg"
    [frappe / wallpaper]="cat.jpg"
    [macchiato / wallpaper]="sea.jpg"
    [mocha / wallpaper]="sea.jpg"
    [gruvbox_light / wallpaper]="cat.jpg"

    # Rofi
    [latte / rofi]="catppuccin-latte.rasi"
    [frappe / rofi]="catppuccin-frappe.rasi"
    [macchiato / rofi]="catppuccin-macchiato.rasi"
    [mocha / rofi]="catppuccin-mocha.rasi"
    [gruvbox_light / rofi]="gruvbox-light.rasi"

    #applets-scripts rofi
    [latte / applet_type]="type-5"
    [latte / applet_style]="style-3.rasi"
    [frappe / applet_type]="type-2"
    [frappe / applet_style]="style-2.rasi"
    [macchiato / applet_type]="type-2"
    [macchiato / applet_style]="style-2.rasi"
    [mocha / applet_type]="type-2"
    [mocha / applet_style]="style-2.rasi"
    [gruvbox_light / applet_type]="type-4"
    [gruvbox_light / applet_style]="style-2.rasi"

    # Tmux
    [latte / tmux]="latte"
    [frappe / tmux]="frappe"
    [macchiato / tmux]="macchiato"
    [mocha / tmux]="mocha"
    [gruvbox_light / tmux]="gruvbox_light"
)

# ------ Fonctions utilitaires ------
die() {
    echo -e "\033[1;31mERREUR: $*\033[0m" >&2
    exit 1
}
info() { echo -e "\033[1;32mINFO: $*\033[0m"; }

check_dependencies() {
    local deps=("feh" "sed")
    for dep in "${deps[@]}"; do
        command -v "$dep" >/dev/null || die "Dépendance manquante: $dep"
    done
}

validate_theme() {
    local valid_themes=("latte" "frappe" "macchiato" "mocha" "gruvbox_light")
    if ! printf '%s\n' "${valid_themes[@]}" | grep -qx "$1"; then
        die "Thème invalide. Choix valides: ${valid_themes[*]}"
    fi
}

# ------ Fonctions de configuration ------
configure_gtk() {

    # Récupérer le thème GTK
    GTK_THEME=${THEMES[$1 / gtk]}

    # Configurer les paramètres GTK
    gnome_schema="org.gnome.desktop.interface"

    # Utiliser gsettings pour configurer les thèmes
    gsettings set $gnome_schema gtk-theme "$GTK_THEME"
    gsettings set $gnome_schema icon-theme "${CONFIG[ICON_THEME]}"
    gsettings set $gnome_schema cursor-theme "${CONFIG[CURSOR_THEME]}"
    gsettings set $gnome_schema font-name "${CONFIG[FONT_NAME]} ${CONFIG[FONT_SIZE]}"

    # Configurer la taille du curseur
    gsettings set org.gnome.desktop.interface cursor-size "${CONFIG[CURSOR_SIZE]}"

    local theme="${THEMES[$1 / gtk]}"
    local config_file="$HOME/.config/gtk-3.0/settings.ini"

    mkdir -p "$(dirname "$config_file")" || die "Impossible de créer le répertoire GTK"

    cat >"$config_file" <<EOF
[Settings]
gtk-theme-name=${theme}
gtk-icon-theme-name=${CONFIG[ICON_THEME]}
gtk-font-name=${CONFIG[FONT_NAME]} ${CONFIG[FONT_SIZE]}
gtk-cursor-theme-name=${CONFIG[CURSOR_THEME]}
gtk-cursor-theme-size=${CONFIG[CURSOR_SIZE]}
EOF

    info "Configuration GTK appliquée: ${theme}"
}

configure_kvantum() {
    local theme="${THEMES[$1 / kvantum]}"
    local config_file="$HOME/.config/Kvantum/kvantum.kvconfig"

    mkdir -p "$(dirname "$config_file")" || die "Impossible de créer le répertoire Kvantum"

    printf "[General]\ntheme=%s\n" "$theme" >"$config_file"
    info "Thème Kvantum appliqué: ${theme}"
}

configure_terminal() {
    # Kitty
    if command -v kitty >/dev/null; then
        local theme="${THEMES[$1 / kitty]}"
        local config_file="$HOME/.config/kitty/colors.conf"
        mkdir -p "$(dirname "$config_file")"
        echo "include ${theme}" >"$config_file"
        info "Configuration Kitty appliquée: ${theme}"
    fi

    # Alacritty
    if command -v alacritty >/dev/null; then
        local theme="${THEMES[$1 / alacritty]}"
        local config_file="$HOME/.config/alacritty/colors.toml"
        mkdir -p "$(dirname "$config_file")"
        echo "general.import = [ \"$HOME/.config/alacritty/themes/${theme}\" ]" >"$config_file"
        info "Configuration Alacritty appliquée: ${theme}"
    fi
}

configure_bat() {
    local theme="${THEMES[$1 / bat]}"
    local config_file="$HOME/.config/bat/config"

    mkdir -p "$(dirname "$config_file")" || die "Impossible de créer le répertoire Bat"

    echo "--theme=\"${theme}\"" >"$config_file"
    if bat cache --build &>/dev/null; then
        info "Thème Bat appliqué: ${theme}"
    else
        die "Échec de la mise à jour du cache Bat"
    fi
}

configure_vim() {
    local theme="${THEMES[$1 / vim]}"
    local config_file="$HOME/.vimrc"

    sed -i '/^colorscheme/d;/^set background/d' "$config_file"
    [[ $1 == "gruvbox_light" ]] && echo "set background=light" >>"$config_file"
    echo "colorscheme ${theme}" >>"$config_file"
    info "Configuration Vim appliquée: ${theme}"
}

configure_nvim() {
    local theme="${THEMES[$1 / nvim]}"
    local config_file="$HOME/.config/nvim/init.lua"

    mkdir -p "$(dirname "$config_file")" || die "Impossible de créer le répertoire Neovim"

    sed -i '/vim.cmd \[\[colorscheme/d;/vim.o.background/d' "$config_file"
    [[ $1 == "gruvbox_light" ]] && echo 'vim.o.background = "light"' >>"$config_file"
    echo "vim.cmd [[colorscheme ${theme}]]" >>"$config_file"
    info "Configuration Neovim appliquée: ${theme}"
}

configure_wallpaper() {
    local wallpaper="${THEMES[$1 / wallpaper]}"
    local wallpaper_path="${CONFIG[WALLPAPER_DIR]}/${wallpaper}"

    if [[ -f "$wallpaper_path" ]]; then
        if [[ "$XDG_SESSION_TYPE" == "x11" ]]; then
            feh --bg-fill "$wallpaper_path" && info "Fond d'écran appliqué avec feh: ${wallpaper}"
        elif [[ "$XDG_SESSION_TYPE" == "wayland" ]]; then
            swaybg -i "$wallpaper_path" -m fill &
            disown && info "Fond d'écran appliqué avec swaybg: ${wallpaper}"
        else
            die "Environnement de bureau non supporté: ${XDG_CURRENT_DESKTOP}"
        fi
    else
        die "Fichier wallpaper introuvable: ${wallpaper_path}"
    fi
}

configure_rofi() {
    local theme="${THEMES[$1 / rofi]}"
    local config_file="$HOME/.config/rofi/config.rasi"
    local theme_path="$HOME/.config/rofi/themes/${theme}"

    # Configuration principale

    [[ -z "$theme" ]] && die "Clé de thème Rofi non trouvée: $theme_key"

    mkdir -p "$(dirname "$config_file")" || die "Impossible de créer le répertoire Rofi"

    if [[ -f "$theme_path" ]]; then
        sed -i '/@theme/d' "$config_file"
        echo "@theme \"${theme_path}\"" >>"$config_file"
        info "Thème Rofi appliqué: ${theme}"
    else
        die "Fichier de thème Rofi introuvable: ${theme_path}"
    fi

    # Configuration des applets
    local applet_type="${THEMES[$1 / applet_type]}"
    local applet_style="${THEMES[$1 / applet_style]}"

    if [[ -n "$applet_type" && -n "$applet_style" ]]; then
        local applet_config="$HOME/.config/rofi/applets/shared/theme.bash"
        mkdir -p "$(dirname "$applet_config")" || die "Échec création dossier applets"

        cat >"$applet_config" <<EOF
type="$HOME/.config/rofi/applets/${applet_type}"
style='${applet_style}'
EOF

        [[ -f "$applet_config" ]] && info "Applet Rofi configuré: ${applet_type}/${applet_style}" || die "Échec configuration applet"
    fi
}

configure_foot() {
    local theme="${THEMES[$1 / foot]}"
    local config_file="$HOME/.config/foot/foot.ini"

    mkdir -p "$(dirname "$config_file")" || die "Impossible de créer le répertoire Foot"

    # Si le fichier existe et contient déjà une ligne "include=", on la remplace
    if [ -f "$config_file" ] && grep -q '^include=' "$config_file"; then
        sed -i "s|^include=.*|include=~/.config/foot/themes/${theme}|" "$config_file"
    else
        # Sinon, on ajoute la ligne sans effacer le reste du fichier
        echo "include=~/.config/foot/themes/${theme}" >>"$config_file"
    fi
    info "Thème Foot appliqué: ${theme}"
}

configure_tmux() {
    local theme="$1"
    local config_file="$HOME/.config/tmux/tmux.conf"
    local catppuccin_plugin="run ~/.config/tmux/plugins/catppuccin/tmux/catppuccin.tmux"

    mkdir -p "$(dirname "$config_file")" || die "Impossible de créer le répertoire Tmux"
    touch "$config_file"

    # Supprimer toutes les lignes contenant "gruvbox" ou "catppuccin"
    sed -i '/gruvbox/d' "$config_file"
    sed -i '/catppuccin/d' "$config_file"

    # Ajouter la nouvelle configuration
    if [[ "$theme" == "gruvbox_light" ]]; then
        echo "set -g @tmux-gruvbox 'light'" >>"$config_file"
        echo "set -g @plugin egel/tmux-gruvbox" >>"$config_file"
    else
        echo "set -g @catppuccin_flavor '$theme'" >>"$config_file"
        echo "$catppuccin_plugin" >>"$config_file"
    fi

    info "Configuration Tmux appliquée: $theme"
}

# ------ Exécution principale ------
main() {
    [[ $# -ne 1 ]] && die "Usage: $0 [latte|frappe|macchiato|mocha|gruvbox_light]"
    local theme="$1"

    check_dependencies
    validate_theme "$theme"

    # Application séquentielle avec gestion d'erreur
    configure_gtk "$theme" || die "Échec configuration GTK"
    configure_kvantum "$theme" || die "Échec configuration Kvantum"
    configure_terminal "$theme" || die "Échec configuration terminal"
    configure_bat "$theme" || die "Échec configuration Bat"
    configure_vim "$theme" || die "Échec configuration Vim"
    configure_nvim "$theme" || die "Échec configuration Neovim"
    configure_wallpaper "$theme" || die "Échec configuration wallpaper"
    configure_rofi "$theme" || die "Échec configuration Rofi"
    configure_foot "$theme" || die "Échec configuration Foot"
    #configure_tmux "$theme" || die "Échec configuration Tmux"

    info "Changement de thème réussi pour '${theme}' !"
}

main "$@"
