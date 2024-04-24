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

          zellij = {
            enable = true;
            enableZshIntegration = true;
            settings = {
              serialize_pane_viewport = true;
              # Seems to pick up on the shell colors just fine?
              # theme = "molokai"; is also a built in option
              theme = "default";
              # Default 10000; repeating here for possible later editing
              scroll_buffer_size = 10000;
            };
          };
        };
      }
    )
  ];
}
