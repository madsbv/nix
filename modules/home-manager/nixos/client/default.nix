{
  mod,
  pkgs,
  flake-root,
  ...
}:

{
  imports = [
    (mod "home-manager/common/client")
    (mod "home-manager/nixos/common")
    # ./dropbox.nix
  ];

  home.packages = with pkgs; [
    signal-desktop
  ];

  xdg.configFile = {
    "awesome" = {
      source = flake-root + "/config/awesome";
      recursive = true;
    };
  };
}
