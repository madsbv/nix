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

let
  name = "Mads Bach Villadsen";
  email = "mvilladsen@pm.me";
in {
  imports = [
    ../common
  ];

  local = {
    terminal.enable = true;
    librewolf = {
      enable = true;
      deviceName = "LibreWolf on ${hostname}";
    };
    ssh.enable = true;
    zathura.enable = true;
    email = {
      enable = lib.mkDefault true;
      maildir = "${config.xdg.dataHome}/Mail";
      muhome = "${config.xdg.cacheHome}/mu";
      muAddressArgs = osConfig.age.secrets.mu-init-addresses.path;
      pmbridge-password = osConfig.age.secrets.pmbridge-password.path;
    };
  };

  home = {
    packages = pkgs.callPackage ../../../modules/home-manager/common/client/packages.nix { inherit nox; };
    sessionPath = ["$HOME/go/bin"];
    sessionVariables.TERMINAL = "kitty";
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
    git.settings.user = { inherit name email; };
  };

  xdg.configFile."tridactyl" = {
    source = flake-root + "/config/tridactyl/";
  };
}
