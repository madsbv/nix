{ config, pkgs, lib, home-manager, doomemacs, my-doomemacs-config, ... }:

let
  user = "mvilladsen";
  # Define the content of your file as a derivation
  myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
    #!/bin/sh
    emacsclient -c -n &
  '';
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };

  my-emacs-mac = pkgs.emacs29-macport.override {
    withNativeCompilation = true;
    withImageMagick = true;
  };
  # According to https://github.com/NixOS/nixpkgs/issues/267548, the with-packages version might cause problems with doom. If so, try my-emacs-mac instead.
  my-emacs-mac-with-packages =
    (pkgs.emacsPackagesFor my-emacs-mac).emacsWithPackages (epkgs:
      with epkgs; [
        pkgs.mu
        treesit-grammars.with-all-grammars
        vterm
        multi-vterm
        pdf-tools
      ]);
  # brew "railwaycat/emacsmacport/emacs-mac", args: ["with-imagemagick", "with-native-compilation", "with-no-title-bars", "with-starter", "with-unlimited-select", "with-xwidgets"]
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
    casks = pkgs.callPackage ./casks.nix { };

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "wireguard" = 1451685025;
      "AdGuard for Safari" = 1440147259;
      "Bitwarden" = 1352778147;
      "MindNode" = 1289197285;
      "Notability" = 360593530;
      "StopTheMadness" = 1376402589;
      "Xcode" = 497799835;
    };
  };

  # TODO: Try to move the xdg, sessionVariables and shellAliases parts into modules/shared somewhere. This requires that we figure out exactly where to set these things in nixos.
  # TODO: Create a '.config' directory in home-manager directory, together with a variable referencing its absolute path in nix, and put non-nix config files in there?

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = { pkgs, config, lib, ... }: {
      xdg.enable = true;
      xdg.configFile."svim".source = ./config/svim;
      home = {
        packages = pkgs.callPackage ./packages.nix { };
        file = lib.mkMerge [
          sharedFiles
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
      };

      programs = {
        emacs = {
          # TODO: Switch over from homebrew
          enable = true;
          package = my-emacs-mac-with-packages;
        };
      } // import ../shared/home-manager.nix { inherit config pkgs lib; };
      # If Doom's emacs or config folder don't already exist, get them from their respective github repos defined in flake.nix.
      # If the emacs folder doesn't exist, install doom following https://github.com/doomemacs/doomemacs/blob/master/docs/getting_started.org#install-doom-manually
      home.activation.installDoomEmacs =
        lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          EMACS_DIR = "${config.xdg.configHome}/emacs"
          DOOM_DIR = "${config.xdg.configHome}/doom"
          if [ ! -d "$DOOM_DIR" ]; then
             ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${my-doomemacs-config}/ DOOM_DIR
          fi
          if [ ! -d "$EMACS_DIR" ]; then
             ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${doomemacs}/ $EMACS_DIR
             PATH = "$EMACS_DIR/bin:$PATH"
             doom sync
             doom env
             emacs --batch -f nerd-icons-install-fonts
          fi
        '';
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
