{ mod, pkgs, ... }:

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

  programs = {
    nm-applet.enable = true;
    firefox.enable = true;
  };
  environment.systemPackages = with pkgs; [
    pavucontrol
    pwvucontrol
  ];

  services = {
    # Provides blueman-applet and blueman-manager for managing bluetooth connections
    blueman.enable = true;

    cinnamon.apps.enable = true;
    xserver = {
      desktopManager.cinnamon = {
        enable = true;
      };
      displayManager.gdm.enable = true;
    };
  };

}
