#1/bin/bash

# ======================== #
#  aliases
# ======================== #

alias tgpt='tgpt --temperature 0'
alias grep='grep --color=auto'

#alias vi="alacritty --config-file ~/.config/alacritty-nvim/alacritty.toml -e nvim &"
#alias vi="foot -c /home/alamine/.config/foot-nvim.ini -e nvim&"

alias startWarp='sudo systemctl start warp-svc.service'
alias stopWarp='sudo systemctl stop warp-svc.service'
alias startWaydroid='sudo systemctl start waydroid-container.service'
alias stopWaydroid='sudo systemctl stop waydroid-container.service'

alias yt-dlp='--downloader aria2c --external-downloader-args "aria2c:-x 3 -s 3 -k 1M" --format "bestvideo[height<=1080]+bestaudio/best" --merge-output-format mkv --embed-chapters --embed-subs --embed-thumbnail -o "~/Videos/yt-dlp/%(uploader)s - %(playlist)s/%(title)s.%(ext)s" '

alias cat="bat"

# Navigation
alias ls='eza  --group-directories-first'
alias ll='eza -l --git  --group-directories-first'
alias la='eza -la --git  --group-directories-first'
alias lt='eza --tree  --level=2'
alias ltd='eza --tree  --only-dirs'

alias ld='eza -l --group-directories-first --only-dirs'
alias lad='eza -l --group-directories-first --only-dirs -a'
alias lf='eza -l --icons --group-directories-first --only-files'
alias laf='eza -l --icons --only-files -a'

alias cd='z'
alias ..='cd ..'
alias ...='cd ../..'

# Gestion de fichiers
alias rm='trash-put -v'
alias empty-trash='trash-empty'

# Système
alias pacup='sudo pacman -Syu && echo -e "\\U2705 System updated!"'
alias pacout='sudo pacman -Rns'
alias pacin='sudo pacman -Syyu'

# Git amélioré
alias gs='git status -sb'
alias ga='git add'
alias gc='git commit -m '
alias gp='git push && echo -e "\\U1F680 Push successful!"'
alias gd='git diff --color-words'

# ======================== #
#     fzf
# ======================== #

export FZF_DEFAULT_COMMAND="fd --type f -H"

# FZF amélioré
export FZF_DEFAULT_OPTS="
--height 70%
--reverse
--border rounded
--ansi
#--color='fg:#abb2bf,bg:#282c34,hl:#98c379'
#--color='fg+:#ffffff,bg+:#2c313a,hl+:#98c379'
#--color='info:#61afef,prompt:#e06c75,pointer:#c678dd'
#--color='marker:#e5c07b,spinner:#56b6c2,header:#56b6c2'
--prompt='   '
--pointer='→'
--marker='✓'
"

check_command() {
    if ! command -v "$1" >/dev/null 2>&1; then
        echo "Erreur: $1 n'est pas installé" >&2
        return 1
    fi
}

batf() {
    check_command bat || return 1
    local file
    file=$(fd -H --exclude "*.mp4" --exlude "*.mkv" --exclude "*.png" --exlude "*.jpg" --exclude"*.jpeg" --exclude "*.mp3" | fzf --bind 'esc:abort' --preview 'bat --color=always {}' --exit-0) && bat --color=always "$file"
}

vimf() {
    check_command vim || return 1
    local file
    file=$(fd -H --exclude "*.pdf" --exclude "*.mp4" --exclude "*.mkv" --exclude "*.png" --exclude "*.jpg" --exclude "*.jpeg" --exclude "*.mp3" | fzf --bind 'esc:abort' -m --exit-0) && vim "$file"
}

vif() {
    check_command nvim || return 1
    local file
    file=$(fd -H --exclude "*.pdf" --exclude "*.mp4" --exclude "*.mkv" --exclude "*.png" --exclude "*.jpg" --exclude "*.jpeg" --exclude "*.mp3" | fzf --bind 'esc:abort' -m --exit-0) && nvim "$file"
}

catf() {
    check_command bat || return 1
    local files
    files=$(fd -H --exclude "pdf" --exclude "*.mp4" --exclude "*.mkv" --exclude "*.png" --exclude "*.jpg" --exclude "*.jpeg" --exclude "*.mp3" | fzf --bind 'esc:abort' --preview 'bat --color=always {}' -m --exit-0) && bat --color=always $files
}

vlcf() {
    check_command vlc || return 1
    check_command fd || return 1

    local file
    file=$(fd --type f -e mp4 -e mkv -e avi -e webm 2>/dev/null |
        fzf --bind 'esc:abort') || return

    [ -f "$file" ] && vlc "$file" &
}

atrilf() {
    check_command atril || return 1
    check_command fd || return 1

    local file
    file=$(fd --type f -e pdf 2>/dev/null |
        fzf --bind 'esc:abort') || return

    [ -f "$file" ] && atril "$file" &
}

cdf() {
    local dir
    dir=$(fd -H --type d | fzf --bind 'esc:abort' --preview 'tree -C {} | head -200' --exit-0) && cd "$dir" || return
}

rhythmboxf() {
    # Vérifier les dépendances
    check_command rhythmbox || return 1
    check_command fd || return 1

    # Chercher et sélectionner un fichier audio
    local file
    file=$(fd --type f -e mp3 -e ogg -e flac -e wav -e m4a 2>/dev/null |
        fzf --bind 'esc:abort') || return

    # Lancer Rhythmbox avec le fichier sélectionné
    if [ -f "$file" ]; then
        rhythmbox "$file" &
    else
        echo "Fichier audio introuvable: $file" >&2
        return 1
    fi
}

rmf() {
    # Vérifier trash-cli
    if ! command -v trash-put &>/dev/null; then
        echo "Install trash-cli: sudo apt install trash-cli"
        return 1
    fi

    # Sélection fichiers/dossiers avec preview
    local targets=($(
        fd --hidden --type f --type d | fzf --multi \
            --preview '[[ -d {} ]] && echo "Dossier:" && tree -C {} | head -200 || bat --color=always {}'
        #--bind 'ctrl-a:select-all,ctrl-d:deselect-all'
    ))

    [[ ${#targets[@]} -eq 0 ]] && return

    # Confirmation
    printf "Déplacer vers la corbeille:\n"
    printf "• %s\n" "${targets[@]}"
    read -rp "Confirmer ? [y/N] " ans
    [[ $ans =~ [yY] ]] && trash-put "${targets[@]}"
}

# Fonction pour afficher la mémoire RAM utilisée par une application
memtake() {
    local application=$1
    local total_ram=0

    # Récupérer les processus correspondant à l'application
    for pid in $(pgrep -f "$application"); do
        # Utiliser ps pour récupérer la mémoire résidente (RSS) en kilo-octets
        local rss=$(ps -p $pid -o rss | tail -n 1)

        # Ajouter la mémoire à la somme totale
        total_ram=$((total_ram + rss))
    done

    # Convertir la somme totale en mégaoctets
    local total_ram_mb=$(bc -l <<<"scale=2; $total_ram / 1024")

    echo "La mémoire RAM totale utilisée par $application est de $total_ram_mb Mo."
}
