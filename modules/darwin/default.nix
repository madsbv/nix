{ inputs, user, config, pkgs, lib, home-manager, my-emacs-mac, doomemacs
, my-doomemacs-config, ... }:

let user = "mvilladsen";

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
    users.${user}.imports = [
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
