{ pkgs, config, lib, user, my-doomemacs-config, ... }:
let
  additionalFiles = import ./files.nix { inherit user config pkgs; };
  emacsDir = "${config.xdg.configHome}/emacs";
  doomDir = "${config.xdg.configHome}/doom";
  doomRepoUrl = "https://github.com/doomemacs/doomemacs";
in {
  imports = [ ../shared/home-manager.nix ];

  xdg.configFile = {
    "svim".source = ./config/svim;
    "sketchybar".source = ./config/sketchybar;
    "karabiner".source = ./config/karabiner;
  };
  home = {
    packages = pkgs.callPackage ./packages.nix { };
    file = additionalFiles;

    stateVersion = "23.11";
    sessionVariables = {
      LESSHISTFILE = "$XDG_CACHE_HOME/lesshst";
      WGETRC = "$XDG_CONFIG_HOME/wgetrc";
      EDITOR = "ec";
      ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
      ZSH_CACHE = "$XDG_CACHE_HOME/zsh";
    };

    shellAliases = {
      wget = "wget --hsts-file=$XDG_CACHE_HOME/.wget-hsts";
      ec = "emacsclient -c -n -a nvim";

      grep = "grep -i --color=always";
      ls = "ls -A -B -F -G -h";
      # Supposedly the space at the end of these aliases should make these commands
      # work with other aliases as input.
      watch = "watch -cd ";
      sudo = "sudo ";
    };
    # TODO: Replace this with the module type structure from hlissner's dotfiles
    # TODO: Replace the rsync stuff with git clone, take the URLs for doom and doom-config as input from flake.nix.inputs
    activation.installDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      if [ ! -d "${doomDir}" ]; then
         ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${my-doomemacs-config}/ ${doomDir}
      fi
      if [ ! -d "${emacsDir}" ]; then
         ${pkgs.git}/bin/git clone --depth=1 --single-branch "${doomRepoUrl}" "${emacsDir}"
         ${emacsDir}/bin/doom install
      fi
    '';
  };

  # NOTE: Trying to use `(pkgs.emacsPackagesFor my-emacs-mac).emacsWithPackages` and an override at the same time breaks things via weird nix double wrapping issues, so use extraPackages instead.
  # TODO: Define a launchd service for emacs daemon? Could be useful, could break tinkering. If yes, see ryan4yin-nix-config for an example.
  programs.emacs = {
    enable = true;
    # TODO: Can I move this to shared/home-manager.nix by taking emacs.package as function input?
    # Patched emacs-macport from overlay
    package = pkgs.my-emacs-mac;
    extraPackages = epkgs:
      with epkgs; [
        # Packages that pull in non-lisp stuff
        # The mu4e epkg also pulls in the mu binary
        mu4e
        treesit-grammars.with-all-grammars
        vterm
        multi-vterm
        pdf-tools
      ];
  };
}
