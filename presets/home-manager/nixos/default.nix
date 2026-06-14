{
  config,
  lib,
  pkgs,
  ...
}:

{
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
}
