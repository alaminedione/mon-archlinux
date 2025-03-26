#!/bin/bash

# Vérifier si libinput est installé
if ! pacman -Qi libinput &> /dev/null; then
    echo "libinput n'est pas installé. Installation..."
    sudo pacman -S --noconfirm libinput
    echo "libinput installé avec succès."
else
    echo "libinput est déjà installé."
fi

# Définir le chemin du fichier de configuration
CONFIG_FILE="/etc/X11/xorg.conf.d/40-libinput.conf"

# Vérifier si le répertoire de configuration existe
if [ ! -d "/etc/X11/xorg.conf.d" ]; then
    echo "Le répertoire /etc/X11/xorg.conf.d n'existe pas. Création du répertoire..."
    sudo mkdir -p /etc/X11/xorg.conf.d
fi


    # Créer le fichier de configuration avec les options de libinput
 sudo bash -c "cat > \"$CONFIG_FILE\" << EOF
Section \"InputClass\"
    Identifier \"libinput touchpad catchall\"
    MatchIsTouchpad \"on\"
    MatchDevicePath \"/dev/input/event*\"
    Driver \"libinput\"
    Option \"Tapping\" \"on\"
    Option \"TappingDrag\" \"on\"
    Option \"TappingButtonMap\" \"lrm\"
EndSection
EOF"

 echo "Fichier de configuration créé avec succès."

