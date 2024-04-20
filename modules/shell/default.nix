{
  pkgs,
  lib,
  config,
  flake-root,
  ...
}:

let
  gitignore_global = [ (builtins.readFile (flake-root + "/config/gitignore_global")) ];
in
{
  # Import all directories in this folder
  imports =
    with builtins;
    filter (p: readFileType p == "directory") (map (p: ./. + "/${p}") (attrNames (readDir ./.)));

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
    };
    # Conflicts with home-managers tmux on Darwin
    tmux.enable = pkgs.stdenv.isLinux;
    direnv.enable = true;
    nix-index.enable = true;
  };

  home-manager.sharedModules = lib.mkIf config.local.hm.enable [
    (
      { pkgs, config, ... }:
      {

        home.sessionVariables = {
          LESSHISTFILE = "${config.xdg.cacheHome}/lesshst";
          WGETRC = "${config.xdg.configHome}/wgetrc";
          ZDOTDIR = "${config.xdg.configHome}/zsh";
          ZSH_CACHE = "${config.xdg.cacheHome}/zsh";
        };
        programs = {
          # Shared shell configuration
          zsh = {
            enable = true;
            enableCompletion = true;
            autosuggestion.enable = true;
            syntaxHighlighting = {
              enable = true;
              highlighters = [
                "main"
                "brackets"
              ];
            };
            # Not sure how this relates to zsh-vi-mode
            # defaultKeymap = "viins";
            autocd = false;
            # Grossly, this is relative to Home, which config.xdg.configHome is not.
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
                { name = "jeffreytse/zsh-vi-mode"; }
                # May need to learn to use: https://github.com/marlonrichert/zsh-autocomplete/
                { name = "marlonrichert/zsh-autocomplete"; }
                { name = "wfxr/forgit"; }
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
                src = lib.cleanSource (flake-root + "/config");
                file = "p10k.zsh";
              }
            ];
            initExtraBeforeCompInit = ''
              # p10k instant prompt
              local P10K_INSTANT_PROMPT="${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
              [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"
            '';
          };

          git = {
            enable = true;
            ignores = gitignore_global;
            extraConfig = {
              init.defaultBranch = "main";
              credential.helper = "store";
              pull.rebase = true;
              rebase.autoStash = true;
              # TODO: Should I just set the editor variable to vim/nvim, and only open files in emacs manually?
              core.editor = "vim";
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
    )
  ];
}
