# This file is called from modules/{darwin,nixos}/home-manager.nix, and is merged into home-manager.programs attribute set.
{ osConfig, config, pkgs, lib, inputs, ... }:

let
  name = "Mads Bach Villadsen";
  email = "mvilladsen@pm.me";
  ssh-identity-file =
    osConfig.age.secrets."ssh-user-${osConfig.networking.hostName}".path;

  gitignore_global = [ (builtins.readFile ./config/gitignore_global) ];
in {
  xdg.enable = true;
  home = {
    packages = pkgs.callPackage ./home-packages.nix { };
    stateVersion = "23.11";
  };
  programs = {
    java.enable = true;
    # pyenv = {
    #   enable = true;
    #   enableZshIntegration = true;
    # };
    bacon = {
      enable = true;
      settings = { };
    };

    # TODO: Move maildirs to XDG_DATA_HOME
    # Also look into home-managers accounts.email options
    mbsync = {
      enable = true;
      extraConfig = builtins.readFile ./config/mbsyncrc;
    };
    mu.enable = true;

    ssh = {
      enable = true;
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          identitiesOnly = true;
        };
      };
      extraOptionOverrides.IdentityFile = ssh-identity-file;
    };

    # Shared shell configuration
    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [ "main" "brackets" ];
      };
      # Not sure how this relates to zsh-vi-mode
      # defaultKeymap = "viins";
      autocd = false;
      cdpath = [ "~/Dropbox/docs/" ];
      dotDir = ".config/zsh";
      history = {
        path = "${config.xdg.dataHome}/zsh/zsh_history";
        ignoreAllDups = true;

      };

      zplug = {
        enable = true;
        zplugHome = "${config.xdg.configHome}/zplug";
        plugins = [
          { name = "ajeetdsouza/zoxide"; }
          {
            name = "jeffreytse/zsh-vi-mode";
          }
          # May need to learn to use: https://github.com/marlonrichert/zsh-autocomplete/
          { name = "marlonrichert/zsh-autocomplete"; }
          {
            name = "wfxr/forgit";
          }
          # { name = "romkatv/powerlevel10k, as:theme, depth:1"; }
        ];
      };

      # TODO: How do I want to balance using nix vs something like zplug as zsh plugin managers? I'd expect to have to do some manual configuration to use nix, as in P10k below...
      plugins = [
        {
          # To customize prompt, `unset POWERLEVEL9K_CONFIG_FILE` and run `p10k configure`.
          # If you don't unset first, p10k will try to overwrite the read-only nix store. This way it just dumps to .config/zsh/p10k.zsh instead.
          name = "powerlevel10k";
          src = pkgs.zsh-powerlevel10k;
          file = "share/zsh-powerlevel10k/powerlevel10k.zsh-theme";
        }
        {
          name = "powerlevel10k-config";
          # TODO: Copy my P10k config over
          src = lib.cleanSource ./config;
          file = "p10k.zsh";
        }
      ];
      initExtraBeforeCompInit = ''
        # p10k instant prompt
        local P10K_INSTANT_PROMPT="${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
        [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"
      '';
      # TODO: This is not machine agnostic, fix
      envExtra = ''
        export RESTIC_CACHE_DIR="/Users/mvilladsen/Library/Caches/restic"
        export PATH="$XDG_CONFIG_HOME/emacs/bin:$HOME/.local/bin:$HOME/.cargo/bin''${PATH+:$PATH}";
      '';
    };

    gh = {
      enable = true;
      settings.editor = "vim";
    };
    git = {
      enable = true;
      ignores = gitignore_global;
      userName = name;
      userEmail = email;
      extraConfig = {
        init.defaultBranch = "main";
        credential.helper = "store";
        pull.rebase = true;
        rebase.autoStash = true;
        # TODO: Should I just set the editor variable to vim/nvim, and only open files in emacs manually?
        core.editor = "vim";
      };
    };

    neovim = {
      enable = true;
      # Symlink vim to nvim
      vimAlias = true;
      plugins = with pkgs.vimPlugins; [
        vim-airline
        vim-airline-themes
        vim-startify
        vim-tmux-navigator
        molokai
        (pkgs.vimPlugins.base16-vim.overrideAttrs (_old:
          let schemeFile = config.scheme inputs.base16-vim;
          in { patchPhase = "cp ${schemeFile} colors/base16-scheme.vim"; }))
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

    kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      # TODO: Either do settings natively in nix, or figure out how to just manage this config file as xdg config?
      extraConfig = builtins.readFile ./config/kitty/kitty.conf
        + builtins.readFile (config.scheme inputs.base16-kitty);
      darwinLaunchOptions = [ "--single-instance" ];
    };

    # mbv: Let's just use this for now
    alacritty = {
      enable = true;
      settings = {
        cursor = { style = "Block"; };

        window = {
          opacity = 1.0;
          padding = {
            x = 24;
            y = 24;
          };
        };

        font = {
          normal = {
            family = "MesloLGS NF";
            style = "Regular";
          };
          size = lib.mkMerge [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 10)
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 14)
          ];
        };

        # Base16 colors
        colors = with config.scheme.withHashtag;
          let
            default = {
              black = base00;
              white = base07;
              inherit red green yellow blue cyan magenta;
            };
          in {
            primary = {
              background = base00;
              foreground = base07;
            };
            cursor = {
              text = base02;
              cursor = base07;
            };
            normal = default;
            bright = default;
            dim = default;
          };
      };
    };

    # mbv: Try this out for now
    tmux = {
      enable = true;
      plugins = with pkgs.tmuxPlugins; [
        vim-tmux-navigator
        sensible
        yank
        prefix-highlight
        {
          plugin = power-theme;
          extraConfig = ''
            set -g @tmux_power_theme 'gold'
          '';
        }
        {
          plugin = resurrect; # Used by tmux-continuum

          # Use XDG data directory
          # https://github.com/tmux-plugins/tmux-resurrect/issues/348
          extraConfig = ''
            set -g @resurrect-dir '$HOME/.cache/tmux/resurrect'
            set -g @resurrect-capture-pane-contents 'on'
            set -g @resurrect-pane-contents-area 'visible'
          '';
        }
        {
          plugin = continuum;
          extraConfig = ''
            set -g @continuum-restore 'on'
            set -g @continuum-save-interval '5' # minutes
          '';
        }
      ];
      terminal = "screen-256color";
      prefix = "C-x";
      escapeTime = 10;
      historyLimit = 50000;
      extraConfig = ''
        # Remove Vim mode delays
        set -g focus-events on

        # Enable full mouse support
        set -g mouse on

        # -----------------------------------------------------------------------------
        # Key bindings
        # -----------------------------------------------------------------------------

        # Unbind default keys
        unbind C-b
        unbind '"'
        unbind %

        # Split panes, vertical or horizontal
        bind-key x split-window -v
        bind-key v split-window -h

        # Move around panes with vim-like bindings (h,j,k,l)
        bind-key -n M-k select-pane -U
        bind-key -n M-h select-pane -L
        bind-key -n M-j select-pane -D
        bind-key -n M-l select-pane -R

        # Smart pane switching with awareness of Vim splits.
        # This is copy paste from https://github.com/christoomey/vim-tmux-navigator
        is_vim="ps -o state= -o comm= -t '#{pane_tty}' \
          | grep -iqE '^[^TXZ ]+ +(\\S+\\/)?g?(view|n?vim?x?)(diff)?$'"
        bind-key -n 'C-h' if-shell "$is_vim" 'send-keys C-h'  'select-pane -L'
        bind-key -n 'C-j' if-shell "$is_vim" 'send-keys C-j'  'select-pane -D'
        bind-key -n 'C-k' if-shell "$is_vim" 'send-keys C-k'  'select-pane -U'
        bind-key -n 'C-l' if-shell "$is_vim" 'send-keys C-l'  'select-pane -R'
        tmux_version='$(tmux -V | sed -En "s/^tmux ([0-9]+(.[0-9]+)?).*/\1/p")'
        if-shell -b '[ "$(echo "$tmux_version < 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\'  'select-pane -l'"
        if-shell -b '[ "$(echo "$tmux_version >= 3.0" | bc)" = 1 ]' \
          "bind-key -n 'C-\\' if-shell \"$is_vim\" 'send-keys C-\\\\'  'select-pane -l'"

        bind-key -T copy-mode-vi 'C-h' select-pane -L
        bind-key -T copy-mode-vi 'C-j' select-pane -D
        bind-key -T copy-mode-vi 'C-k' select-pane -U
        bind-key -T copy-mode-vi 'C-l' select-pane -R
        bind-key -T copy-mode-vi 'C-\' select-pane -l
      '';
    };
  };
}
