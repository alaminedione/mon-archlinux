#!/bin/bash

# Colors
GREEN='\033[1;32m'
BLUE='\033[1;34m'
RED='\033[1;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No color

echo -e "${BLUE}### Arch Linux Setup Script ###${NC}"

# Function to ask for user confirmation
confirm_action() {
    echo -ne "${YELLOW}$1 (y/n): ${NC}"
    read -r CONFIRM
    if [[ "$CONFIRM" =~ ^[Nn]$ ]]; then
        echo -e "${RED}Skipping...${NC}"
        return 1
    fi
    return 0
}

# Step 1: Update the system
if confirm_action "Do you want to update the system?"; then
    echo -e "${YELLOW}Updating the system...${NC}"
    sudo pacman -Syyu --noconfirm
    echo -e "${GREEN}System update completed.${NC}"
fi

# Step 2: Disable specified services
if confirm_action "Do you want to disable unnecessary services?"; then
    SERVICES=(
        "apparmor.service"
        "avahi-daemon.service"
        "avahi-daemon.socket"
        "NetworkManager-wait-online.service"
        "bluetooth.service"
        "pcscd.socket"
        "cloud-config.service"
        "cloud-final.service"
        "remote-fs.target"
        "cloud-init-local.service"
        "cups.path"
        "sshd.service"
        "cups.service"
        "cups.socket"
        "getty@.service"
        "hv_kvp_daemon.service"
        "hv_vss_daemon.service"
        "ufw.service"
        "ModemManager.service"
        "wpa_supplicant.service"
    )

    echo -e "${YELLOW}Disabling unnecessary services...${NC}"
    for SERVICE in "${SERVICES[@]}"; do
        echo -e "${BLUE}Disabling ${SERVICE}...${NC}"
        sudo systemctl disable --now $SERVICE 2>/dev/null
    done
    echo -e "${GREEN}Services disabled.${NC}"
fi

# Step 3: Install required packages
if confirm_action "Do you want to install packages?"; then
    PACKAGES=(
        "debugedit"
        "megasync-bin"
        "ungoogled-chromium-bin"
        "telegram-desktop"
        # "redshift"
        "kitty"
        "obsidian"
        "zed"
        "freedownloadmanager"
        "tgpt"
        "yt-dlp"
        "zoxide"
        "asciinema"
        "bat"
        "cht.sh"
        "github-cli"
        "stow"
        "nodejs"
        "pnpm"
        "typescript"
        "php"
        "pip"
        "composer"
        "neovim"
        "npm"
        "eza"
        "mycli"
        "mariadb"
        "gammastep"
        "fastfetch"
        "onefetch"
        "qemu-full"
        "vitualbox"
        "stacer"
        "onlyoffice"
        "xbeset",
        "hyperfine",
	"hoppscotch-bin"

    )

    # Select packages to install
    echo -e "${YELLOW}Select packages to install (separate numbers with spaces, or enter 'all' to install everything):${NC}"
    for i in "${!PACKAGES[@]}"; do
        echo -e "${BLUE}[$i] ${PACKAGES[i]}${NC}"
    done

    echo -ne "${YELLOW}Enter selection: ${NC}"
    read -r SELECTION

    if [[ "$SELECTION" == "all" ]]; then
        SELECTED_PACKAGES=("${PACKAGES[@]}")
    else
        SELECTED_PACKAGES=()
        for index in $SELECTION; do
            SELECTED_PACKAGES+=("${PACKAGES[$index]}")
        done
    fi

    # Install selected packages
    echo -e "${YELLOW}Installing selected packages...${NC}"
    for PACKAGE in "${SELECTED_PACKAGES[@]}"; do
        echo -e "${BLUE}Installing ${PACKAGE}...${NC}"
        yay -S --needed --noconfirm $PACKAGE
    done

    echo -e "installe zsh plugins "
    git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions

    echo -e "${GREEN}Package installation completed.${NC}"
fi

# Step 4: Set up BlackArch repository
if confirm_action "Do you want to set up the BlackArch repository?"; then
    echo -e "${YELLOW}Setting up BlackArch repository...${NC}"
    curl -O https://blackarch.org/strap.sh
    sudo chmod +x strap.sh &&
        sudo ./strap.sh &&
        rm strap.sh
    echo -e "${GREEN}BlackArch repository setup completed.${NC}"
    echo -e "${YELLOW}Updating the system with BlackArch repository...${NC}"
    sudo pacman -Syyu
fi

# Step 5: install whitesur (qt macbook theme)
if confirm_action "Do you want to install whitesur theme(MacOS like theme for all gtk based app or even desktops)?"; then
    echo -e "${YELLOW}Installing whitesur theme...${NC}"
    # Cloner le dépôt Git
    git clone https://github.com/vinceliuice/WhiteSur-kde.git

    # Entrer dans le répertoire Kvantum
    cd WhiteSur-kde/Kvantum || {
        echo "Échec de l'accès au répertoire Kvantum"
        exit 1
    }

    # Installer le thème WhiteSur
    if [ -d "WhiteSur" ]; then
        cp -r WhiteSur ~/.config/Kvantum/ # Copier le thème dans le répertoire de configuration de Kvantum
        echo "Thème WhiteSur copié avec succès."
    else
        echo "Le répertoire WhiteSur n'existe pas."
    fi

    # Installer le thème WhiteSur-opaque
    if [ -d "WhiteSur-opaque" ]; then
        cp -r WhiteSur-opaque ~/.config/Kvantum/ # Copier le thème dans le répertoire de configuration de Kvantum
        echo "Thème WhiteSur-opaque copié avec succès."
    else
        echo "Le répertoire WhiteSur-opaque n'existe pas."
    fi

    # Appliquer les thèmes avec Kvantum Manager
    kvantummanager --set-theme WhiteSur        # Appliquer le thème WhiteSur
    kvantummanager --set-theme WhiteSur-opaque # Appliquer le thème WhiteSur-opaque

    echo "Les thèmes ont été appliqués avec succès. Veuillez redémarrer vos applications Qt pour voir les changements."

    # Supprimer le répertoire Kvantum
    cd ..
    rm -rf Kvantum

    #install macOs icons
    git clone https://github.com/vinceliuice/WhiteSur-icon-theme.git
    cd WhiteSur-icon-theme
    chmod +x install.sh
    ./install.sh -a
    cd ..
    rm -rf WhiteSur-icon-theme
    echo "Les icônes ont été installé avec succès. Veuillez redémarrer vos applications Qt pour voir les changements."
    echo "n'oublier pas de choisir les icons de macos dans les parametres de qt"

    # echo -e "${GREEN}Whitesur theme installation completed.${NC}"
    echo -e "${GREEN} veuillez installer les themes copié sur ~/.config/Kvantum/ manuellement avec Kvantum ${NC}"
fi

# add script run_at_startup to run some commands at startup
if confirm_action "Do you want to add script run_at_startup.sh to run some commands at startup?"; then
    echo -e "${YELLOW}Adding script run_at_startup.sh to run some commands at startup...${NC}"

    # Vérifier si le script run_at_start.sh existe
    if [ ! -f "run_at_start.sh" ]; then
        echo "Erreur : le fichier run_at_start.sh n'existe pas dans le répertoire courant."
        exit 1
    fi

    # Copier le script dans /etc/profile.d/
    sudo cp run_at_start.sh /etc/profile.d/

    # Vérifier si la commande cp a réussi
    if [ $? -eq 0 ]; then
        echo "Le script 'run_at_start.sh' a été copié avec succès dans '/etc/profile.d/'."
    else
        echo "Erreur lors de la copie du script."
        exit 1
    fi

    # Ajouter l'utilisateur au fichier sudoers pour exécuter le script sans mot de passe
    USERNAME=$(whoami)

    # Vérifier si l'utilisateur existe déjà dans le fichier sudoers
    if sudo grep -q "^$USERNAME ALL=(ALL) NOPASSWD: /etc/profile.d/run_at_start.sh" /etc/sudoers; then
        echo "L'utilisateur '$USERNAME' est déjà configuré pour exécuter le script sans mot de passe."
    else
        # Ajouter la ligne au fichier sudoers en utilisant un éditeur temporaire
        {
            echo "$USERNAME ALL=(ALL) NOPASSWD: /etc/profile.d/run_at_start.sh"
        } | sudo tee -a /etc/sudoers >/dev/null

        if [ $? -eq 0 ]; then
            echo "L'utilisateur '$USERNAME' a été ajouté au fichier sudoers avec succès."
        else
            echo "Erreur lors de l'ajout de l'utilisateur au fichier sudoers."
            exit 1
        fi
    fi

    echo "Configuration terminée. Le script sera exécuté automatiquement au démarrage."

fi
