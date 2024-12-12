{
  config,
  lib,
  ...
}:

let
  cfg = config.local.neovim;
in
{
  options.local.neovim = {
    enable = lib.mkEnableOption "Neovim";
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = lib.mkIf config.local.hm.enable [
      (
        { pkgs, ... }:
        {
          programs.neovim = {
            enable = true;
            vimAlias = true;
            viAlias = true;
            defaultEditor = true;
            plugins = with pkgs.vimPlugins; [
              vim-airline
              vim-airline-themes
              vim-startify
              molokai
              (pkgs.vimPlugins.base16-vim.overrideAttrs (
                _old:
                let
                  schemeFile = config.scheme base16-vim;
                in
                {
                  patchPhase = "cp ${schemeFile} colors/base16-scheme.vim";
                }
              ))
            ];
            extraConfig = ''
              "" General
              set number
              set history=1000
              set nocompatible
              set modelines=0
              set encoding=utf-8
              set scrolloff=3
              set showmode
              set showcmd
              set hidden
              set wildmenu
              set wildmode=list:longest
              set cursorline
              set ttyfast
              set nowrap
              set ruler
              set backspace=indent,eol,start
              set laststatus=2

              " Dir stuff
              set nobackup
              set nowritebackup
              set noswapfile
              set backupdir=~/.config/vim/backups
              set directory=~/.config/vim/swap

              " Relative line numbers for easy movement
              set relativenumber
              set rnu

              "" Whitespace rules
              set tabstop=8
              set shiftwidth=2
              set softtabstop=2
              set expandtab

              "" Searching
              set incsearch
              set gdefault

              "" Statusbar
              set nocompatible " Disable vi-compatibility
              set laststatus=2 " Always show the statusline
              let g:airline_theme='molokai'
              let g:airline_powerline_fonts = 1

              "" Local keys and such
              let mapleader=","
              let maplocalleader=" "

              "" Change cursor on mode
              :autocmd InsertEnter * set cul
              :autocmd InsertLeave * set nocul

              "" File-type highlighting and configuration
              syntax on
              filetype on
              filetype plugin on
              filetype indent on

              "" Paste from clipboard
              nnoremap <Leader>, "+gP

              "" Copy from clipboard
              xnoremap <Leader>. "+y

              "" Move cursor by display lines when wrapping
              nnoremap j gj
              nnoremap k gk

              "" Map leader-q to quit out of window
              nnoremap <leader>q :q<cr>

              "" Move around split
              nnoremap <C-h> <C-w>h
              nnoremap <C-j> <C-w>j
              nnoremap <C-k> <C-w>k
              nnoremap <C-l> <C-w>l

              "" Easier to yank entire line
              nnoremap Y y$

              "" Move buffers
              nnoremap <tab> :bnext<cr>
              nnoremap <S-tab> :bprev<cr>

              "" Like a boss, sudo AFTER opening the file to write
              cmap w!! w !sudo tee % >/dev/null

              let g:startify_lists = [
                \ { 'type': 'dir',       'header': ['   Current Directory '. getcwd()] },
                \ { 'type': 'sessions',  'header': ['   Sessions']       },
                \ { 'type': 'bookmarks', 'header': ['   Bookmarks']      }
                \ ]

              let g:startify_bookmarks = [
                \ '~/.local/share/src',
                \ ]

              " base16
              set termguicolors background=dark
              " let base16colorspace=256
              " colorscheme base16-scheme
              colorscheme molokai
            '';
            # NOTE: Molokai was originally a vim theme modified from Monokai, so just use the native one here.
            # Can we do this programmatically depending on color-scheme? Would be pretty convoluted
          };
        }
      )
    ];
  };
}
