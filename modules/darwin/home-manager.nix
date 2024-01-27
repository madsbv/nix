{ config, pkgs, lib, home-manager, ... }:

let
  user = "mvilladsen";
  # Define the content of your file as a derivation
  myEmacsLauncher = pkgs.writeScript "emacs-launcher.command" ''
    #!/bin/sh
    emacsclient -c -n &
  '';
  sharedFiles = import ../shared/files.nix { inherit config pkgs; };
  additionalFiles = import ./files.nix { inherit user config pkgs; };
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

  # Enable home-manager
  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { pkgs, config, lib, ... }: {
      home = {
        packages = pkgs.callPackage ./packages.nix { };
        file = lib.mkMerge [
          sharedFiles
          additionalFiles
          { "emacs-launcher.command".source = myEmacsLauncher; }
        ];

        stateVersion = "23.11";
      };
      programs = { }
        // import ../shared/home-manager.nix { inherit config pkgs lib; };
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

  # TODO: Try to move the following into modules/shared somewhere.
  # TODO: Create a '.config' directory in home-manager directory, together with a variable referencing its absolute path in nix, and put non-nix config files in there?
  xdg.enable = true;

  home.sessionVariables = {
    LESSHISTFILE = "$XDG_CACHE_HOME/lesshst";
    WGETRC = "$XDG_CONFIG_HOME/wgetrc";
    EDITOR = "ec";
    ZDOTDIR = "$XDG_CONFIG_HOME/zsh";
    ZSH_CACHE = "$XDG_CACHE_HOME/zsh";
  };

  home.shellAliases = {
    wget = "wget --hsts-file=$XDG_CACHE_HOME/.wget-hsts";
    ec = "emacsclient -c -n -a nvim";

    grep = "grep -i --color=always";
    ls = "ls -A -B -F -G -h";
    # Supposedly the space at the end of these aliases should make these commands
    # work with other aliases as input.
    watch = "watch -cd ";
    sudo = "sudo ";
  };

}
