{
  flake-root,
  config,
  pkgs,
  homebrew-bundle,
  homebrew-core,
  homebrew-cask,
  homebrew-services,
  homebrew-cask-fonts,
  felixkratz-formulae,
  pirj-noclamshell,
  mod,
  nox,
  ...
}:

# Just a single user on this machine
let
  user = "mvilladsen";
in
{
  imports = [
    ./dock
    ./homebrew
    ./autorestic.nix
    (mod "shared/secrets/email.nix")
  ];

  age.secrets."mbv-mba.autorestic.yml".rekeyFile =
    flake-root + "/secrets/other/mbv-mba.autorestic.yml.age";
  local = {
    autorestic.ymlFile = config.age.secrets."mbv-mba.autorestic.yml".path;
    ssh-clients.users = [ user ];
  };

  users.users.${user} = {
    home = "/Users/${user}";
    isHidden = false;
    # Set as users.defaultShell on nixos, but that option doesn't exist on nix-darwin
    shell = pkgs.zsh;
  };

  nix-homebrew = {
    enable = true;
    user = "${user}";
    taps = {
      "homebrew/homebrew-core" = homebrew-core;
      "homebrew/homebrew-cask" = homebrew-cask;
      "homebrew/homebrew-bundle" = homebrew-bundle;
      "homebrew/homebrew-cask-fonts" = homebrew-cask-fonts;
      "homebrew/homebrew-services" = homebrew-services;
      "felixkratz/homebrew-formulae" = felixkratz-formulae;
      "pirj/homebrew-noclamshell" = pirj-noclamshell;
    };
    mutableTaps = false;
  };

  home-manager = {
    users.${user} = {
      imports = [ ./home-manager.nix ];
    };
    # Arguments exposed to every home-module
    extraSpecialArgs = {
      inherit user nox;
    };
  };

  # TODO: Configure
  # Fully declarative dock using the latest from Nix Store
  local = {
    dock = {
      enable = true;
      entries = [
        { path = "/System/Applications/Messages.app/"; }
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
