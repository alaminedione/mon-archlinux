#!/usr/bin/env bash

# Script d'installation complet pour Arch Linux
set -eo pipefail

# Configuration
LOG_FILE="$HOME/install_arch.log"
YAY_URL="https://aur.archlinux.org/yay.git"

# Couleurs
BOLD=$(tput bold)
RED="${BOLD}$(tput setaf 1)"
GREEN="${BOLD}$(tput setaf 2)"
YELLOW="${BOLD}$(tput setaf 3)"
BLUE="${BOLD}$(tput setaf 4)"
RESET=$(tput sgr0)

echo "desinstaller ces apps et les reinstaller avec yay sauf gvim qui va venir avec vim"
sudo pacman -R vim sxhkd bspwm --noconfirm

# Liste complète des paquets
OFFICIAL_PACKAGES=(
    node-ts
    sway swaylock swayidle swaybg   wl-clipboard
    hyperfine
    noto-fonts noto-fonts-cjk noto-fonts-emoji noto-fonts-extra
    ttf-liberation ttf-dejavu ttf-roboto
    ttf-jetbrains-mono ttf-fira-code ttf-hack
    adobe-source-code-pro-fonts

    polkit bash-completion xdg-user-dirs libnotify gvim dconf
    xorg-xinput xorg-xrandr xorg-xsetroot vulkan-tools
    gvfs debugedit rsync unzip clipcat maim xclip
    pavucontrol vlc fd thunar thunar-archive-plugin
    tumbler thunar-volman thunar-media-tags-plugin
    cheese trash-cli tree
    python-pip python-pipx yt-dlp aria2 gtk-engine-murrine
    atril brightnessctl pamixer atomicparsley
    ffmpeg fastfetch stow clapper git glab nodejs
    npm pnpm php composer jq python uv docker podman
    drawio-desktop ripgrep rhythmbox dbeaver obs-studio
    obsidian-icon-theme kitty alacritty bat eza starship
    zoxide ranger neovim tgpt feh dunst picom
    kvantum viewnior ttf-dejavu ttf-liberation
    ttf-bitstream-vera ttf-jetbrains-mono-nerd
    qt6-svg qt6-declarative qt5-quickcontrols2 grim
    # Lancez l'authentification avec GitHub
    gh auth login
)

AUR_PACKAGES=(
    ttf-amiri ttf-scheherazade wlrobs 
    xcb-imdkit
    zen-browser-bin obsidian telegram-desktop anki-bin
    onlyoffice-bin megasync-bin freedownloadmanager
    cht.sh-git appflowy-bin tdrop bspwm-git sxhkd-git
    stacer-bin iwgtk xkbset amixer light betterlockscreen zeal
    xfce4-power-manager   rofi-lbonn-wayland-git flameshot-git
)

# Fonctions principales ######################################################

init_logging() {
    exec > >(tee -a "$LOG_FILE") 2>&1
    trap 'handle_error $? "Interruption utilisateur"' SIGINT
    trap 'handle_error $? "Erreur de commande"' ERR
}

show_header() {
    clear
    echo -e "${BLUE}"
    echo "████████████████████████████████████████████████████████████████████"
    echo "█                    Installation Arch Linux                      █"
    echo "████████████████████████████████████████████████████████████████████"
    echo -e "${RESET}"
}

handle_error() {
    local code=$1
    local context=$2
    echo -e "\n${RED}ERREUR (${code}): ${context}${RESET}"
    echo -e "${YELLOW}Consultez le log: ${LOG_FILE}${RESET}"
    exit $code
}

install_yay() {
    if ! command -v yay >/dev/null; then
        echo -e "\n${GREEN}>>> Installation de yay...${RESET}"
        sudo pacman -S --needed --noconfirm git base-devel
        local temp_dir=$(mktemp -d)
        git clone "${YAY_URL}" "${temp_dir}"
        (cd "${temp_dir}" && makepkg -si --noconfirm)
        rm -rf "${temp_dir}"
    fi
}

install_packages() {
    local -n packages=$1
    local repo=$2
    echo -e "\n${GREEN}>>> Installation des paquets (${repo})...${RESET}"

    for pkg in "${packages[@]}"; do
        if [[ $repo == "official" ]] && pacman -Qi $pkg &>/dev/null; then
            echo -e "${YELLOW}✓ ${pkg} (déjà installé)${RESET}"
            continue
        fi

        if [[ $repo == "aur" ]] && yay -Qi $pkg &>/dev/null; then
            echo -e "${YELLOW}✓ ${pkg} (déjà installé)${RESET}"
            continue
        fi

        echo -n "• ${pkg} "
        if [[ $repo == "official" ]]; then
            sudo pacman -S --noconfirm $pkg >/dev/null &
        else
            yay -S --noconfirm $pkg >/dev/null &
        fi

        local pid=$!
        wait $pid && echo -e "${GREEN}[OK]${RESET}" || handle_error $? "Échec installation $pkg"
    done
}

post_install() {
    echo -e "\n${GREEN}>>> Configuration post-installation...${RESET}"

    # Vim-plug
    echo -n "• Configuration vim-plug "
    mkdir -p ~/.vim/autoload
    curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim &&
        echo -e "${GREEN}[OK]${RESET}" || handle_error $? "vim-plug"

    # Aider-chat
    #    echo -n "• Installation aider-chat "
    #    pipx install aider-chat \
    #        && echo -e "${GREEN}[OK]${RESET}" || handle_error $? "aider-chat"
}

show_summary() {
    echo -e "\n${GREEN}>>> Installation terminée avec succès!${RESET}"
    echo -e "• ${BLUE}Paquets officiels: ${#OFFICIAL_PACKAGES[@]}"
    echo -e "• ${BLUE}Paquets AUR: ${#AUR_PACKAGES[@]}"
    echo -e "• ${BLUE}Log complet: ${LOG_FILE}"
    echo -e "\n${YELLOW}Redémarrez votre système pour appliquer les changements!${RESET}"
}

# Workflow ####################################################################

main() {
    init_logging
    show_header

    # Vérifications initiales
    [[ -f /etc/arch-release ]] || handle_error 1 "Système non supporté"
    [[ $(id -u) -eq 0 ]] && handle_error 1 "Exécution en root détectée"

    # Installation
    install_yay
    install_packages OFFICIAL_PACKAGES "official"
    install_packages AUR_PACKAGES "aur"
    post_install

    show_summary
}

# Exécution ###################################################################

[[ "${BASH_SOURCE[0]}" == "${0}" ]] && main
