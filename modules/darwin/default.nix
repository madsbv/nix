{ inputs, user, config, pkgs, lib, home-manager, my-emacs-mac, doomemacs
, my-doomemacs-config, ... }:

let
  user = "mvilladsen";

  xdg_configHome = "/Users/mvilladsen/.config";
  emacsDir = "${xdg_configHome}/emacs";
  doomDir = "${xdg_configHome}/doom";
in {
  # imports = [ ./dock ./homebrew ./secrets.nix ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = {
      imports = [
        ./home-manager.nix
        # {
        #   inherit inputs;
        # }
        # {
        #   inherit inputs pkgs config lib my-doomemacs-config doomemacs
        #     my-emacs-mac;
        # }
        # {
        #   # TODO: We can probably pass around things like user in this way as well
        #   inherit config pkgs lib home-manager my-emacs-mac doomemacs
        #     my-doomemacs-config;
        # }
      ];
      # TODO: Replace this with the module type structure from hlissner's dotfiles
      home.activation.installDoomEmacs =
        home-manager.lib.hm.dag.entryAfter [ "writeBoundary" ] ''
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
    # Arguments exposed to every home-module
    # extraSpecialArgs = {
    #   inherit pkgs config lib my-doomemacs-config doomemacs my-emacs-mac;
    # };
  };

  # # TODO: Configure
  # # Fully declarative dock using the latest from Nix Store
  # local = {
  #   dock = {
  #     enable = true;
  #     entries = [
  #       {
  #         path = "/System/Applications/Messages.app/";
  #       }
  #       # Kitty or Alacritty?
  #       { path = "${pkgs.alacritty}/Applications/Alacritty.app/"; }
  #       { path = "/System/Applications/Music.app/"; }
  #       {
  #         path = "/System/Applications/Photos.app/";
  #       }
  #       # {
  #       #   path = toString myEmacsLauncher;
  #       #   section = "others";
  #       # }
  #       {
  #         path = "${config.users.users.${user}.home}/.local/share/";
  #         section = "others";
  #         options = "--sort name --view grid --display folder";
  #       }
  #       {
  #         path = "${config.users.users.${user}.home}/.local/share/downloads";
  #         section = "others";
  #         options = "--sort name --view grid --display stack";
  #       }
  #     ];
  #   };
  # };

}
