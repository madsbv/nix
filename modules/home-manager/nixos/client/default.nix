{ pkgs, mod, ... }:

{
  imports = [
    (mod "home-manager/common/client")
    (mod "home-manager/nixos/common")
  ];
}
