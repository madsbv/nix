{
  flake-root,
  pkgs,
  lib,
  ...
}:
{
  imports = [ self.modules.home.common-client ];

  xdg.configFile = {
    "svim".source = flake-root + "/config/svim";
    "sketchybar".source = flake-root + "/config/sketchybar";
    "karabiner".source = flake-root + "/config/karabiner";
  };

  home = {
    packages = pkgs.callPackage ./packages.nix { };
  };
  programs = {
    kitty.darwinLaunchOptions = [ "--single-instance" ];
    # Awaiting GTK3 fix: https://nixpk.gs/pr-tracker.html?pr=449689
    librewolf.enable = lib.mkForce false;
  };
}
