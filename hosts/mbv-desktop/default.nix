{ mod, ... }:

{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    (mod "system/nixos/server")
    (mod "services/media-server")
  ];

  nixpkgs.config = {
    cudaSupport = true;
  };
  services = {
    # Provides blueman-applet and blueman-manager for managing bluetooth connections
    blueman.enable = true;
  };
}
