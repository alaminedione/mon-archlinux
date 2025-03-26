#!/bin/bash
# Vérifie si le répertoire ~/.profile.d existe
if [ -d "$HOME/.profile.d" ]; then
    # Boucle à travers chaque fichier .sh dans ~/.profile.d
    for script in "$HOME/.profile.d/"*.sh; do
        # Vérifie si le fichier est lisible
        if [ -r "$script" ]; then
            # Sourcing du script
            source "$script"
        fi
    done
    unset script
fi

