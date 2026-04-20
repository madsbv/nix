{
  pkgs,
  flake-root,
  homeManagerModules,
  ...
}:

{
  imports = [
    homeManagerModules.dropbox
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
