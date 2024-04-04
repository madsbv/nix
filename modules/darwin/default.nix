{ user, flake-root, config, pkgs, doomemacs, my-doomemacs-config, color-scheme
, ... }@inputs:

{
  imports = [ ./dock ./homebrew ];

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
        inputs.base16.homeManagerModule
        { scheme = color-scheme; }
      ];
    };
    # Arguments exposed to every home-module
    extraSpecialArgs = {
      inherit my-doomemacs-config doomemacs user inputs flake-root;
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
          path = "${config.users.users.${user}.home}/Dropbox/docs/work";
          section = "others";
          options = "--sort name --view grid --display folder";
        }
        {
          path = "${config.users.users.${user}.home}/Downloads";
          section = "others";
          options = "--sort name --view grid --display stack";
        }
      ];
    };
  };
}
