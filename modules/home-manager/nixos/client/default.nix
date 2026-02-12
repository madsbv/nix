{
  pkgs,
  flake-root,
  modules,
  ...
}:

{
  imports = [
    ./dropbox.nix
  ]
  ++ (with modules; [
    home.common-client
    home.nixos-common
  ]);

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
