{
  lib,
  pkgs,
  ...
}:
let
  user = "mvilladsen";

in
{
  environment.systemPackages = with pkgs; [ docker ];
  virtualisation.docker.enable = lib.mkIf pkgs.stdenv.isLinux true;
  users.users.${user}.extraGroups = [ "docker" ];
}
