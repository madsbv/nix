{
  user,
  config,
  lib,
  osConfig,
  hostname,
  pkgs,
  flake-root,
  nox,
  inputs,
  ...
}:

# Home manager configuration for graphical client machines.

let
  # Really just for git
  name = "Mads Bach Villadsen";
  email = "mvilladsen@pm.me";
in
{
  imports = [
    ../../../../presets/home-manager/common
  ];

  home = {
    packages = pkgs.callPackage ./packages.nix { inherit nox; };
  };

  local = {
    email = {
      enable = lib.mkDefault true;
      maildir = "${config.xdg.dataHome}/Mail";
      muhome = "${config.xdg.cacheHome}/mu";
      muAddressArgs = osConfig.age.secrets.mu-init-addresses.path;
      pmbridge-password = osConfig.age.secrets.pmbridge-password.path;
    };
  };

  home = {
    sessionPath = [ "$HOME/go/bin" ];
    sessionVariables = {
      TERMINAL = "kitty";
    };
  };

  programs = {
    go = {
      enable = true;
      env.GOPATH = "${config.home.homeDirectory} go";
    };

    gh = {
      enable = true;
      settings.editor = "vim";
    };
    git.settings.user = {
      inherit name email;
    };
  };
}
