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
    less = "${pkgs.less}/bin/less --ignore-case --LINE-NUMBERS";
    # TODO: Themeing?
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
  };

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

        home = {
          sessionVariables = {
            LESSHISTFILE = "${config.xdg.cacheHome}/lesshst";
            WGETRC = "${config.xdg.configHome}/wgetrc";
            ZDOTDIR = "${config.xdg.configHome}/zsh";
            ZSH_CACHE = "${config.xdg.cacheHome}/zsh";
          };
          # The duplicate here is for the sake of Nix-Darwin, which currently places aliases in .zprofile, which doesn't get loaded by Zellij's non-login shells.
          # TODO: Remove once fixed.
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
                src = lib.cleanSource (flake-root + "/config/p10k");
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
