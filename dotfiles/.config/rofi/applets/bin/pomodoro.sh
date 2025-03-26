#!/usr/bin/env bash

## Applet : Pomodoro Timer avec affichage dynamique

# Importation du thème
source "$HOME/.config/rofi/applets/shared/theme.bash"
theme="$type/$style"

# Configuration
prompt='Pomodoro Timer'
mesg="Appuyez sur Entrée pour démarrer ou arrêter."
font_size="11.3"          # Taille de police personnalisée
window_width="900px"      # Largeur augmentée
padding_size="20px"

# Durées par défaut (en minutes)
WORK_TIME=25
SHORT_BREAK=5
LONG_BREAK=15

# Variables globales
TIMER_PID=""
TIMER_TYPE=""
TIMER_REMAINING=0
IS_RUNNING=false

# Commande Rofi
rofi_cmd() {
    rofi -theme-str "window {width: $window_width;}" \
         -theme-str "element-text {font: \"JetBrains Mono Nerd Font $font_size\";}" \
         -theme-str "window {padding: $padding_size;}" \
         -theme-str "element {padding: 10px 15px;}" \
         -theme-str "textbox-prompt-colon {str: \"\"; size: 20px;}" \
         -theme-str "scrollbar {width: 14px;}" \
         -dmenu -p "$prompt" -mesg "$mesg" -markup-rows \
         -theme "$theme"
}

# Formater le temps en MM:SS
format_time() {
    local total_seconds=$1
    printf "%02d:%02d" $((total_seconds / 60)) $((total_seconds % 60))
}

# Afficher le menu dynamique
show_menu() {
    if $IS_RUNNING; then
        echo -e "⏹ Arrêter\n⏳ Temps restant : $(format_time "$TIMER_REMAINING")\nType : $TIMER_TYPE"
    else
        echo -e "🍅 Pomodoro ($WORK_TIME min)\n☕ Pause courte ($SHORT_BREAK min)\n😴 Pause longue ($LONG_BREAK min)"
    fi
}

# Lancer un minuteur
start_timer() {
    local duration=$1
    TIMER_TYPE=$2
    TIMER_REMAINING=$((duration * 60))
    IS_RUNNING=true

    # Boucle de décompte
    while [[ $TIMER_REMAINING -gt 0 ]]; do
        sleep 1
        TIMER_REMAINING=$((TIMER_REMAINING - 1))
        # Mettre à jour l'affichage dynamique
        show_menu | rofi_cmd > /dev/null &
    done

    # Notification à la fin
    notify-send "⏰ $TIMER_TYPE terminé !" "Cliquez pour continuer."

    # Réinitialiser le minuteur
    IS_RUNNING=false
    TIMER_PID=""
    TIMER_TYPE=""
    TIMER_REMAINING=0
}

# Boucle principale pour l'affichage dynamique
main_loop() {
    while true; do
        # Afficher le menu et capturer la sélection
        choice=$(show_menu | rofi_cmd)

        case "$choice" in
            "🍅 Pomodoro ("*)
                start_timer "$WORK_TIME" "Pomodoro" &
                TIMER_PID=$!
                ;;
            "☕ Pause courte ("*)
                start_timer "$SHORT_BREAK" "Pause courte" &
                TIMER_PID=$!
                ;;
            "😴 Pause longue ("*)
                start_timer "$LONG_BREAK" "Pause longue" &
                TIMER_PID=$!
                ;;
            "⏹ Arrêter")
                kill $TIMER_PID 2>/dev/null
                IS_RUNNING=false
                TIMER_PID=""
                TIMER_TYPE=""
                TIMER_REMAINING=0
                notify-send "⏹ Minuteur arrêté" "La session a été interrompue."
                ;;
            *)
                break
                ;;
        esac
    done
}

# Démarrer la boucle principale
main_loop
