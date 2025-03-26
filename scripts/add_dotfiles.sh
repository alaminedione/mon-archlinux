#!/bin/bash

# Clone dotfiles repository
DOTFILES_DIR="$HOME/dotfiles"
if [ ! -d "$DOTFILES_DIR" ]; then
    git clone https://gitlab.com/mon-archlinux/dotfiles "$DOTFILES_DIR"
fi

# Copy all files (including hidden) from dotfiles to home directory
if [ -d "$DOTFILES_DIR" ]; then
    cp -vr "$DOTFILES_DIR"/. "$HOME"
else
    echo "Error: Dotfiles directory not found." >&2
    exit 1
fi

echo "Dotfiles copied successfully!"
