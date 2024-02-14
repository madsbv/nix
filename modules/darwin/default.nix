{ user, config, pkgs, lib, home-manager, doomemacs, my-doomemacs-config, ...
}@inputs:

{
  imports = [ ./dock ./homebrew ./secrets.nix ];

  users.users.${user} = {
    name = "${user}";
    home = "/Users/${user}";
    isHidden = false;
    shell = pkgs.zsh;
  };

  home-manager = {
    useGlobalPkgs = true;
    users.${user} = { imports = [ ./home-manager.nix ]; };
    # Arguments exposed to every home-module
    extraSpecialArgs = { inherit my-doomemacs-config doomemacs user; };
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
