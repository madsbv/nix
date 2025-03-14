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
    ./dropbox.nix
  ];

  home.packages = with pkgs; [
    signal-desktop
    libreoffice-qt
    hunspell
    hunspellDicts.en_US
    hunspellDicts.da_DK
  ];

  services = {
    # Screenshot tool
    flameshot = {
      enable = true;
    };
  };

  xdg.configFile = {
    "awesome" = {
      source = flake-root + "/config/awesome";
      recursive = true;
    };
  };
}
