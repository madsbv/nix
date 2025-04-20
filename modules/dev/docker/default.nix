_: {
  # TODO: docker/podman options (in system or home-manager) do not support Darwin. How to configure?
  # For now we're just configuring these in every nixos system in system/nixos/common
  #
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
