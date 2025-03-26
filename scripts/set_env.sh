#!/bin/bash

# Variables à définir
VARIABLE1="ELECTRON_ENABLE_LOGGING=true"
VARIABLE2="ELECTRON_OZONE_PLATFORM_HINT=auto"
VARIABLE3="GVIM_ENABLE_WAYLAND=1"

# Chemin vers le fichier /etc/environment
ENV_FILE="/etc/environment"

# Vérifie si le fichier existe
if [ ! -f "$ENV_FILE" ]; then
  echo "Le fichier $ENV_FILE n'existe pas. Création..."
  sudo touch "$ENV_FILE"
fi

# Ajoute ou modifie les variables dans le fichier
echo "$VARIABLE1" | sudo tee -a "$ENV_FILE"
echo "$VARIABLE2" | sudo tee -a "$ENV_FILE"
echo "$VARIABLE3" | sudo tee -a "$ENV_FILE"

echo "Variables ajoutées avec succès."
