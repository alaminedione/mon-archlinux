#!/bin/bash

# Configuration
ALLOWED_SCHEDULE=(
    "Lun-Sam 08:00 13:00"
    "Lun-Sam 14:10 16:50"
    "Lun-Sam 17:10 19:00"
    "Lun-Ven 20:00 22:00"
    "Dim 08:00 13:00"
    "Dim 20:00 22:00"
)

SHUTDOWN_DELAY=10 # Délai en secondes

# --------------------------------------------------
# Logique de contrôle
# --------------------------------------------------
declare -A DAYS_MAP=([Lun]=1 [Mar]=2 [Mer]=3 [Jeu]=4 [Ven]=5 [Sam]=6 [Dim]=7)

convert_day_range() {
    local input=$1
    if [[ $input =~ - ]]; then
        local start=${DAYS_MAP[${input%-*}]}
        local end=${DAYS_MAP[${input#*-}]}
        echo $(seq $start $end)
    else
        echo ${DAYS_MAP[$input]}
    fi
}

check_access() {
    local current_day=$(date +%u)
    local current_time=$(date +%H:%M)
    local access_granted=false

    for entry in "${ALLOWED_SCHEDULE[@]}"; do
        read -ra parts <<<"$entry"
        days_range=${parts[0]}
        start_time=${parts[1]}
        end_time=${parts[2]}

        allowed_days=$(convert_day_range "$days_range")

        if [[ " $allowed_days " =~ " $current_day " ]]; then
            # Correction ShellCheck : utilisation de ! < et ! >
            if [[ ! "$current_time" < "$start_time" ]] && [[ ! "$current_time" > "$end_time" ]]; then
                access_granted=true
                break
            fi
        fi
    done

    if $access_granted; then
#        wall "Accès autorisé - Période valide"
#	exit 0
    else
  #      wall "Contrôle Temps: Extinction dans $SHUTDOWN_DELAY secondes !" # Unité corrigée
      # sleep $SHUTDOWN_DELAY
 #      sudo shutdown -h now
    fi
}

check_access
