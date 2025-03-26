#!/usr/bin/env bash

# Catppuccin GRUB Theme Installer
# Version: 2.1
# Auteur: Votre Nom

set -euo pipefail

# Configuration
REPO_URL="https://github.com/catppuccin/grub.git"
CLONE_DIR="/tmp/catppuccin-grub"
THEME_DIR="/usr/share/grub/themes"
GRUB_CONFIG="/etc/default/grub"
BACKUP_DIR="/etc/default/grub.bak"
FLAVORS=("latte" "frappe" "macchiato" "mocha")
DEFAULT_FLAVOR="mocha"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Fonction d'affichage d'erreur
error_exit() {
    echo -e "${RED}[ERREUR]${NC} $1" >&2
    exit 1
}

# Aide
show_help() {
    echo -e "${GREEN}Usage: $0 [options]"
    echo
    echo "Options:"
    echo "  -f <flavor>    Choisir la variante de couleur (${FLAVORS[*]})"
    echo "  -u             Désinstaller le thème"
    echo "  -h             Afficher cette aide"
    echo
    echo "Exemples:"
    echo "  $0 -f mocha     # Installer la variante Mocha"
    echo "  $0 -u           # Désinstaller le thème"
    exit 0
}

# Vérifier les dépendances
check_dependencies() {
    local deps=("git" "sudo" "grub-mkconfig")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" >/dev/null 2>&1; then
            error_exit "Dépendance manquante : $dep"
        fi
    done
}

# Installer le thème
install_theme() {
    local flavor="$1"
    local theme_name="catppuccin-${flavor}-grub-theme"
    local theme_path="${THEME_DIR}/${theme_name}"
    
    echo -e "${BLUE}[1/4]${NC} Téléchargement du thème..."
    if [ -d "$CLONE_DIR" ]; then
        git -C "$CLONE_DIR" pull --ff-only || error_exit "Échec de la mise à jour du dépôt"
    else
        git clone --depth 1 "$REPO_URL" "$CLONE_DIR" || error_exit "Échec du clonage"
    fi

    echo -e "${BLUE}[2/4]${NC} Installation des fichiers..."
    sudo mkdir -p "$THEME_DIR"
    sudo rsync -a --delete "${CLONE_DIR}/src/${theme_name}/" "$theme_path/"

    echo -e "${BLUE}[3/4]${NC} Configuration de GRUB..."
    [ ! -f "$GRUB_CONFIG" ] && sudo touch "$GRUB_CONFIG"
    sudo cp "$GRUB_CONFIG" "$BACKUP_DIR-$(date +%Y%m%d%H%M%S)"

    if grep -q "^GRUB_THEME=" "$GRUB_CONFIG"; then
        sudo sed -i "s|^GRUB_THEME=.*|GRUB_THEME=\"${theme_path}/theme.txt\"|" "$GRUB_CONFIG"
    else
        echo -e "\n# Catppuccin GRUB Theme" | sudo tee -a "$GRUB_CONFIG" >/dev/null
        echo "GRUB_THEME=\"${theme_path}/theme.txt\"" | sudo tee -a "$GRUB_CONFIG" >/dev/null
    fi

    echo -e "${BLUE}[4/4]${NC} Mise à jour de GRUB..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg || error_exit "Échec de la génération de la configuration GRUB"
}

# Désinstaller le thème
uninstall_theme() {
    echo -e "${YELLOW}[1/3]${NC} Suppression des fichiers..."
    sudo rm -rf "${THEME_DIR}/catppuccin-"*-grub-theme

    echo -e "${YELLOW}[2/3]${NC} Réinitialisation de la configuration..."
    if [ -f "$GRUB_CONFIG" ]; then
        sudo sed -i '/^# Catppuccin GRUB Theme$/d' "$GRUB_CONFIG"
        sudo sed -i '/^GRUB_THEME=.*catppuccin.*$/d' "$GRUB_CONFIG"
    fi

    echo -e "${YELLOW}[3/3]${NC} Mise à jour de GRUB..."
    sudo grub-mkconfig -o /boot/grub/grub.cfg || error_exit "Échec de la régénération de GRUB"
}

# Vérification des arguments
flavor="$DEFAULT_FLAVOR"
uninstall=false

while getopts ":f:uh" opt; do
    case $opt in
        f) flavor="$OPTARG" ;;
        u) uninstall=true ;;
        h) show_help ;;
        :) error_exit "L'option -$OPTARG nécessite un argument" ;;
        \?) error_exit "Option invalide: -$OPTARG" ;;
    esac
done

# Execution principale
main() {
    check_dependencies

    if "$uninstall"; then
        uninstall_theme
        echo -e "${GREEN}Désinstallation terminée avec succès!${NC}"
    else
        if [[ ! " ${FLAVORS[*]} " =~ " ${flavor} " ]]; then
            error_exit "Variante invalide! Choisissez parmi : ${FLAVORS[*]}"
        fi
        
        install_theme "$flavor"
        echo -e "${GREEN}Installation terminée! Variante ${flavor} activée.${NC}"
    fi
}

# Démarrage
main
