{
  flake-root,
  pkgs,
  mod,
  ...
}:
{
  imports = [ (mod "home-manager/common/client") ];

  xdg.configFile = {
    "svim".source = flake-root + "/config/svim";
    "sketchybar".source = flake-root + "/config/sketchybar";
    "karabiner".source = flake-root + "/config/karabiner";
  };

  home = {
    packages = pkgs.callPackage ./packages.nix { };
  };
  programs.kitty.darwinLaunchOptions = [ "--single-instance" ];
}
