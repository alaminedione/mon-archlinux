#!/bin/bash

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

# ======================== #
#  VARIABLE ENVIROONEMENTS #
# ======================== #

if [[ ":$PATH:" != *":$HOME/.local/bin:"* ]]; then
    export PATH="$HOME/.local/bin:$PATH"
fi

# ajouter les sources de ~/.profile.d/
# for i in ~/.profile.d/*.sh; do
#     if [ -r "$i" ]; then
#         source "$i"
#     fi
# done

source ~/.profile.d/run.sh
source ~/.profile.d/env.aider.sh

export EDITOR=vim
export VISUAL=gvim


export STARSHIP_CONFIG=~/.config/starship.toml
export EXA_ICON_SPACING=2

export HISTSIZE=3000
export HISTSIZE=10000000
export HISTCONTROL=ignoredups
export HISTIGNORE="ls:cd:pwd"

export HISTTIMEFORMAT="%F %T   "

# ======================== #
#  CONFIGURATION DE BASE   #
# ======================== #

# Configuration spécifique à Bash
shopt -s histappend
# set -o vi

alias ls='ls --color=auto'
alias grep='grep --color=auto'
PS1='\[\e[1;32m\]\u@\h\[\e[0m\] \[\e[1;34m\]\W\[\e[0m\] \[\e[1;35m\]➜\[\e[0m\] '

# ======================== #
#  aliases
# ======================== #

source ~/.aliases.sh

# ======================== #
#  OPTIMISATIONS FINALES   #
# ======================== #

#enable bash autocompletion
if [ -f /usr/share/bash-completion/bash_completion ]; then
    . /usr/share/bash-completion/bash_completion
fi

# Chargement différé pour performances
defer_init() {
    command -v "$1" >/dev/null && eval "$("$@")"
}

defer_init starship init bash
defer_init zoxide init bash
defer_init fzf --bash
