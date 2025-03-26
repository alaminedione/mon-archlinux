set clipboard=unnamed,unnamedplus
set nocompatible
set termguicolors
set t_Co=256

syntax on           " Active la coloration syntaxique
filetype on         " Active la détection du type de fichier
filetype plugin on  " Active les plugins spécifiques au type de fichier
filetype indent on  " Active l'indentation spécifique au type de fichier


call plug#begin()

" Plug 'tpope/vim-sensible'
Plug 'catppuccin/vim', { 'as': 'catppuccin' }
Plug 'morhetz/gruvbox'
Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app && npm install' }
call plug#end()





colorscheme catppuccin_mocha
