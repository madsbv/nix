{ mod, flake-root, ... }:

{
  imports = [
    (mod "home-manager/common/client")
    (mod "home-manager/nixos/common")
  ];
  xdg.configFile = {
    "awesome".source = flake-root + "/config/awesome";
  };
}
