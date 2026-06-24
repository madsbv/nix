{
  config,
  lib,
  osConfig,
  pkgs,
  nox,
  ...
}:

# Home manager configuration for graphical client machines.

{
  imports = [
    ../../../../presets/home-manager/common
  ];

  home = {
    packages = pkgs.callPackage ./packages.nix { inherit nox; };
    sessionPath = [ "$HOME/go/bin" ];
    sessionVariables.TERMINAL = "kitty";
  };

  local = {
    email = {
      enable = lib.mkDefault true;
      maildir = "${config.xdg.dataHome}/Mail";
      muhome = "${config.xdg.cacheHome}/mu";
      muAddressArgs = osConfig.age.secrets.mu-init-addresses.path;
      pmbridgePasswordFile = osConfig.age.secrets.pmbridge-password.path;
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
  };
}
