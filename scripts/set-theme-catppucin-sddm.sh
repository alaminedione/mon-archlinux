#!/bin/bash

# Fonction pour afficher les messages d'erreur
function error_message() {
    echo -e "\e[31m[Erreur]\e[0m $1"
}

# copier les  thèmes Catppuccin
sudo cp -r ./ressources/sddm-catppuccin/* /usr/share/sddm/themes/

# Configuration de SDDM pour utiliser le thème Mocha
echo "Configuration de SDDM..."
sddm_conf="/etc/sddm.conf"
if [ ! -f "$sddm_conf" ]; then
sudo    echo -e "[Theme]\nCurrent=catppuccin-mocha" >"$sddm_conf"
else
sudo    sed -i 's/^Current=.*/Current=catppuccin-mocha/' "$sddm_conf"
fi

echo "Installation des thèmes Catppuccin terminée. Le thème Mocha est appliqué."
