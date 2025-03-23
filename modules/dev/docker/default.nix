{
  lib,
  pkgs,
  config,
  ...
}:
let
  user = "mvilladsen";
in
{
  # TODO: docker/podman options (in system or home-manager) do not support Darwin. How to configure?
  # We could try to exclude import of this file from dev/, or just universally enable this on linux through system, or not enable any services and just install packages.
  # environment.systemPackages = with pkgs; [
  #   docker
  #   podman
  # ];
  # users.users.${user}.extraGroups = [ "docker" ];
  # virtualisation = {
  #   docker.enable = true;
  #   podman.enable = true;
  # };
}
