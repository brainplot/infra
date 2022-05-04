" Syntax highlighting
syntax on
if $TERM =~ '-256color$'
    set termguicolors
endif

" General options
set autoindent
set backspace=indent,eol,start
set complete-=i
set formatoptions+=j
set nocompatible
set noswapfile
set noundofile
set number
set relativenumber
set shiftwidth=2
set viminfo=
set viminfofile=NONE
set wildmenu

" Indentation and file automatic recognition
filetype indent plugin on
