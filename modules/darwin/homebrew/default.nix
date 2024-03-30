{ pkgs, ... }:

{

  homebrew = {
    enable = true;
    onActivation = {
      cleanup = "uninstall";
      upgrade = true;
    };
    casks = pkgs.callPackage ./casks.nix { };

    brews = [
      # System stuff
      # Note: Noclamshell works on current system, might need to brew services start it on a new install though.
      "pirj/noclamshell/noclamshell"
      "felixkratz/formulae/borders"
      "felixkratz/formulae/svim"
    ];

    # These app IDs are from using the mas CLI app
    # mas = mac app store
    # https://github.com/mas-cli/mas
    #
    # $ nix shell nixpkgs#mas
    # $ mas search <app name>
    #
    masApps = {
      "WireGuard" = 1451685025;
      "AdGuard for Safari" = 1440147259;
      "Bitwarden" = 1352778147;
      "MindNode" = 1289197285;
      "Notability" = 360593530;
      "StopTheMadness" = 1376402589;
      "Xcode" = 497799835;
      "com.kagimacOS.Kagi-Search" = 1622835804;
    };
  };
}
