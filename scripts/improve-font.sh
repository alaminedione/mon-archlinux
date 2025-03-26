#!/bin/bash

# Script pour améliorer le rendu des polices sur Arch Linux

#  Créer le fichier de configuration XML
echo "Création du fichier de configuration XML..."
CONFIG_DIR="$HOME/.config/fontconfig"
CONFIG_FILE="$CONFIG_DIR/fonts.conf"

if [ ! -f "$CONFIG_FILE" ]; then
    mkdir -p "$CONFIG_DIR"
    cat <<EOL >"$CONFIG_FILE"
<?xml version="1.0"?>
<!DOCTYPE fontconfig SYSTEM "urn:fontconfig:fonts.dtd">
<fontconfig>
  <!-- Paramètres généraux de rendu -->
  <match target="font">
    <edit name="antialias" mode="assign"><bool>true</bool></edit>
    <edit name="hinting" mode="assign"><bool>true</bool></edit>
    <edit name="rgba" mode="assign"><const>rgb</const></edit>
    <edit name="hintstyle" mode="assign"><const>hintslight</const></edit>
    <edit name="lcdfilter" mode="assign"><const>lcddefault</const></edit>
    <edit name="size" mode="assign"><double>12.0</double></edit>
  </match>

  <!-- Définition des polices par défaut avec support arabe -->
  <alias>
    <family>serif</family>
    <prefer>
      <family>Amiri</family>         <!-- Police arabe style classique -->
      <family>Noto Serif</family>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
    </prefer>
  </alias>

  <alias>
    <family>sans-serif</family>
    <prefer>
      <family>Noto Sans Arabic</family> <!-- Police arabe moderne -->
      <family>Noto Sans</family>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
    </prefer>
  </alias>

  <alias>
    <family>sans</family>
    <prefer>
      <family>Noto Sans Arabic</family>
      <family>Noto Sans</family>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
    </prefer>
  </alias>

  <alias>
    <family>monospace</family>
    <prefer>
      <family>JetBrainsMono</family>
      <family>Noto Sans Arabic</family> <!-- Supporte l'arabe en monospace -->
      <family>Noto Mono</family>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
    </prefer>
  </alias>

  <alias>
    <family>mono</family>
    <prefer>
      <family>JetBrainsMono</family>
      <family>Noto Sans Arabic</family>
      <family>Noto Mono</family>
      <family>Noto Color Emoji</family>
      <family>Noto Emoji</family>
    </prefer>
  </alias>
</fontconfig>
EOL
else
    echo "Le fichier de configuration existe déjà : $CONFIG_FILE"
fi

# Étape 3 : Désactiver les polices bitmap (commentée par défaut)
# echo "Désactivation des polices bitmap..."
# [code resté identique mais commenté]

# Étape 4 : Configurer les paramètres X11
XRES_FILE="$HOME/.Xresources"
XFT_SETTINGS=(
    "Xft.lcdfilter: lcddefault"
    "Xft.hintstyle: hintslight"
    "Xft.hinting: 1"
    "Xft.antialias: 1"
    "Xft.rgba: rgb"
)

if command -v xrdb &>/dev/null; then
    echo "Configuration des paramètres X11..."
    touch "$XRES_FILE"

    for setting in "${XFT_SETTINGS[@]}"; do
        if ! grep -q "^$setting" "$XRES_FILE"; then
            echo "$setting" >>"$XRES_FILE"
        fi
    done

    xrdb -merge "$XRES_FILE"
else
    echo "xorg-xrdb n'est pas installé. Pour l'installer :"
    echo "sudo pacman -S xorg-xrdb"
fi

# Étape 5 : Créer des liens symboliques
CONF_DIR="$HOME/.config/fontconfig/conf.d"
CONFIGS=(
    "10-sub-pixel-rgb.conf"
    "10-hinting-slight.conf"
    "11-lcdfilter-default.conf"
)

echo "Création des liens symboliques..."
mkdir -p "$CONF_DIR"

for conf in "${CONFIGS[@]}"; do
    src="/usr/share/fontconfig/conf.avail/$conf"
    dest="$CONF_DIR/$conf"

    if [ -f "$src" ]; then
        if [ ! -e "$dest" ]; then
            ln -svf "$src" "$dest"
        else
            echo "Le lien existe déjà : $dest"
        fi
    else
        echo "Fichier source introuvable : $src"
    fi
done

# Étape 6 : Éditer le fichier freetype2.sh
echo "Édition du fichier freetype2.sh..."
FREETYPE_FILE="/etc/profile.d/freetype2.sh"

if [ -f "$FREETYPE_FILE" ]; then
    sudo sed -i 's/^#export FREETYPE_PROPERTIES="truetype:interpreter-version=40"/export FREETYPE_PROPERTIES="truetype:interpreter-version=40"/' "$FREETYPE_FILE"
else
    echo "Freetype2 n'est pas installé. Pour l'installer :"
    echo "sudo pacman -S freetype2"
fi

# Étape 7 : Rafraîchir le cache des polices
echo "Rafraîchissement du cache des polices..."
sudo fc-cache -fv

# Étape 8 : Reboot recommandé
echo -e "\nAmélioration du rendu des polices terminée !\n"
echo "Pour appliquer les changements :"
echo "1. Soit redémarrer votre session"
echo "2. Soit exécuter :"
echo "   systemctl restart display-manager.service"
