{
  pkgs,
  lib,
  config,
  flake-root,
  ...
}:

let
  gitignore_global = [ (builtins.readFile (flake-root + "/config/gitignore_global")) ];
  flakedir = if pkgs.stdenv.isDarwin then "/Users/mvilladsen/.config/nix/" else "/etc/nixos/nix/";
  shellAliases = {
    gj = "${pkgs.just}/bin/just ${flakedir}";
    j = "${pkgs.just}/bin/just";
    ls = "${pkgs.eza}/bin/eza --binary --header --git --git-repos --all";
    l = "ls -alh";
    less = "${pkgs.less}/bin/less --ignore-case --LINE-NUMBERS";
    cat = "${pkgs.bat}/bin/bat";
    grep = "${pkgs.gnugrep}/bin/grep -i --color=always";
    psgrep = "ps aux | grep -v grep | grep";
  };
in
{
  # Import all directories in this folder
  imports =
    with builtins;
    filter (p: readFileType p == "directory") (map (p: ./. + "/${p}") (attrNames (readDir ./.)));

  environment = {
    inherit shellAliases;
    # For zsh completion of system packages.
    pathsToLink = [ "/share/zsh" ];
    systemPackages = [ pkgs.zsh-autocomplete ];
  };

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
    };
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
    nix-index.enable = true;
  };

  home-manager.sharedModules = lib.mkIf config.local.hm.enable [
    (
      { pkgs, config, ... }:
      {

        home = {
          sessionVariables = {
            LESSHISTFILE = "${config.xdg.cacheHome}/lesshst";
            WGETRC = "${config.xdg.configHome}/wgetrc";
            ZDOTDIR = "${config.xdg.configHome}/zsh";
            ZSH_CACHE = "${config.xdg.cacheHome}/zsh";
          };
          # The duplicate here is for the sake of Nix-Darwin, which currently places aliases in .zprofile, which doesn't get loaded by Zellij's non-login shells.
          # TODO: Remove once fixed.
          # TODO: Create a PR to actually fix this.
          # https://github.com/LnL7/nix-darwin/issues/886
          shellAliases = shellAliases // {
            wget = "${pkgs.wget}/bin/wget --hsts-file=${config.xdg.cacheHome}/.wget-hsts";
            f = "z";
            fj = "zi";
          };
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
            dotDir = "${config.xdg.configHome}/zsh";
            history = {
              path = "${config.xdg.dataHome}/zsh/zsh_history";
              ignoreAllDups = true;
            };

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
                src = lib.cleanSource (flake-root + "/config/zsh-plugins/p10k-config");
                file = "p10k.zsh";
              }
              {
                name = "vi-mode";
                src = pkgs.zsh-vi-mode;
                file = "share/zsh-vi-mode/zsh-vi-mode.plugin.zsh";
              }
            ];
            initContent = lib.mkOrder 550 ''
              # p10k instant prompt
              local P10K_INSTANT_PROMPT="${config.xdg.cacheHome}/p10k-instant-prompt-''${(%):-%n}.zsh"
              [[ ! -r "$P10K_INSTANT_PROMPT" ]] || source "$P10K_INSTANT_PROMPT"
              source ${pkgs.zsh-autocomplete}/share/zsh-autocomplete/zsh-autocomplete.plugin.zsh
            '';

            enableVteIntegration = true;
          };

          zoxide = {
            enable = true;
            enableZshIntegration = true;
          };

          # Terminal file manager
          yazi = {
            enable = true;
            enableZshIntegration = true;
          };

          git = {
            enable = true;
            ignores = gitignore_global;
            settings = {
              init.defaultBranch = "main";
              credential.helper = "store";
              pull.rebase = true;
              rebase.autoStash = true;
              # TODO: Should I just set the editor variable to vim/nvim, and only open files in emacs manually?
              core.editor = "vim";
            };
          };

          bat = {
            enable = true;
            config = {
              theme = "base16";
            };
            extraPackages = with pkgs.bat-extras; [
              # batdiff
              batman
              batgrep
            ];
          };

          zellij = {
            enable = true;
            # This just enables autostart in zsh. I don't want that on client machines.
            enableZshIntegration = lib.mkDefault false;
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
