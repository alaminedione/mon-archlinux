#!/usr/bin/env bash

# Script d'installation directe
set -eo pipefail

# Configuration
LOG_FILE="$HOME/install.log"
WALLPAPER_MAIN="$HOME/.config/bspwm/wallpaper/cat.jpg"
WALLPAPER_LOCK="$HOME/.config/bspwm/wallpaper/sea.jpg"

# Couleurs
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
NC='\033[0m'

# Nettoyer et initialiser
echo "" >"$LOG_FILE"
mkdir -p "$HOME/.install_backups"

# Fonction de log
log() {
    echo -e "$1"
    echo "$(date +"%T") - $2" >>"$LOG_FILE"
}

# Fonction de vérification de fichiers
check_file() {
    if [ ! -f "$1" ]; then
        echo -e "${RED}Erreur: Le fichier '$1' est introuvable!${NC}"
        exit 1
    fi
}

# Vérifications de base
check_file "/etc/arch-release" || {
    echo -e "${RED}Seulement pour Arch Linux!${NC}"
    exit 1
}
[ "$EUID" -eq 0 ] && {
    echo -e "${RED}Ne pas lancer en root!${NC}"
    exit 1
}

# Installation principale
{
    # Paquets de base
    log "${GREEN}[1/6] Installation des apps principales...${NC}" "Début installation apps"
    check_file "./install_my_lovely_apps.sh"
    ./install_my_lovely_apps.sh || {
        echo -e "${RED}Erreur lors de l'installation des applications principales.${NC}"
        exit 1
    }

    # Configuration système
    log "${GREEN}[2/6] Création répertoires...${NC}" "Création répertoires utilisateur"
    xdg-user-dirs-update

    # Dotfiles
    log "${GREEN}[3/6] Application des dotfiles...${NC}" "Début dotfiles"
    check_file "./add_dotfiles.sh"
    ./add_dotfiles.sh || {
        echo -e "${RED}Erreur lors de l'application des dotfiles.${NC}"
        exit 1
    }

    # Personnalisations
    log "${GREEN}[4/6] Optimisation des polices...${NC}" "Début optimisation polices"
    ./improve-font.sh
    ./set-theme-catppucin-grub.sh
    ./set-theme-catppucin-sddm.sh

    # Configuration matériel
    log "${GREEN}[5/6] Configuration périphériques...${NC}" "Début configuration touchpad"
    check_file "./activate-touchpad-click.sh"
    ./activate-touchpad-click.sh || {
        echo -e "${RED}Erreur lors de la configuration du touchpad.${NC}"
        exit 1
    }

    #set environnement
    log "${GREEN}[6/6] Configuration de l'environnement...${NC}" "Début configuration environnement"
    check_file "./set_env.sh"
    ./set_env.sh || {
        echo -e "${RED}Erreur lors de la configuration de l'environnement.${NC}"
        exit 1
    }

    # Finalisation
    log "${GREEN}[6/6] Dernières personnalisations...${NC}" "Configuration wallpaper"
    betterlockscreen -u "$WALLPAPER_LOCK"
    #feh --bg-fill "$WALLPAPER_MAIN"

} | tee -a "$LOG_FILE"

#zsh
chsh -s $(which zsh)
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
git clone https://github.com/zsh-users/zsh-completions.git ~/.oh-my-zsh/custom/plugins/zsh-completions


# Résultat final
echo -e "\n${GREEN}Installation terminée!${NC}"
echo "Redémarrage recommandé. Log complet: $LOG_FILE"
