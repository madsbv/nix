{ config, pkgs, lib, home-manager, my-emacs-mac, doomemacs, my-doomemacs-config
, ... }:

let
  user = "mvilladsen";
  # Define the content of your file as a derivation
  myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
    #!/bin/sh
    emacsclient -c -n &
  '';
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };

  # HACK: Manual specification of xdg config dir, should figure out how to access config.xdg.configHome. Maybe do the xdg stuff in a separate file earlier in the process, programs later? That would make sense anyway.
  xdg_configHome = "${config.users.users.${user}.home}/.config";
  emacsDir = "${xdg_configHome}/emacs";
  doomDir = "${xdg_configHome}/doom";

in {
  imports = [ ./dock ];

  # It me
  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  homebrew = {
    enable = true;
    onActivation.cleanup = "uninstall";
    casks = pkgs.callPackage ./casks.nix { };

    brews = [
      # System stuff
      # Note: Noclamshell works on current system, might need to brew services start it on a new install though.
      "pirj/noclamshell/noclamshell"
      "felixkratz/formulae/borders"
      "felixkratz/formulae/svim"
    ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "WireGuard" = 1451685025;
      "AdGuard for Safari" = 1440147259;
      "Bitwarden" = 1352778147;
      "MindNode" = 1289197285;
      "Notability" = 360593530;
      "StopTheMadness" = 1376402589;
      "Xcode" = 497799835;
    };
  };

  # TODO: Try to move the xdg, sessionVariables and shellAliases parts into modules/shared somewhere. This requires that we figure out exactly where to set these things in nixos.

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }: {
      xdg.enable = true;
      xdg.configFile."svim".source = ./config/svim;
      home = {
        packages = pkgs.callPackage ./packages.nix { };
        file = lib.mkMerge [
          sharedFiles
          # TODO: Do I need all the scripts and launchers for emacs?
          additionalFiles
          { "emacs-launcher.command".source = myEmacsLauncher; }
        ];

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
        # If Doom's emacs or config folder don't already exist, get them from their respective github repos defined in flake.nix.
        # If the emacs folder doesn't exist, install doom
        activation.installDoomEmacs =
          lib.hm.dag.entryAfter [ "writeBoundary" ] ''
            if [ ! -d "${doomDir}" ]; then
               ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${my-doomemacs-config}/ ${doomDir}
            fi
            if [ ! -d "${emacsDir}" ]; then
               ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${doomemacs}/ ${emacsDir}
               export PATH="${emacsDir}/bin:$PATH"
               doom install
            fi
          '';

      };
      programs = {
        # Note: Trying to use `(pkgs.emacsPackagesFor my-emacs-mac).emacsWithPackages` and an override at the same time breaks things via weird nix double wrapping issues, so use extraPackages instead.
        # TODO: Define a launchd service for emacs daemon? Could be useful, could break tinkering. If yes, see ryan4yin-nix-config for an example.
        emacs = {
          enable = true;
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
      } // import ../shared/home-manager.nix { inherit config pkgs lib; };
    };
  };

  # TODO: Configure
  # Fully declarative dock using the latest from Nix Store
  local = {
    dock = {
      enable = true;
      entries = [
        {
          path = "/System/Applications/Messages.app/";
        }
        # Kitty or Alacritty?
        { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
        { path = "/System/Applications/Music.app/"; }
        { path = "/System/Applications/Photos.app/"; }
        {
          path = toString myEmacsLauncher;
          section = "others";
        }
        {
          path = "${config.users.users.${user}.home}/.local/share/";
          section = "others";
          options = "--sort name --view grid --display folder";
        }
        {
          path = "${config.users.users.${user}.home}/.local/share/downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };

}
