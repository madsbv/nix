{ pkgs, lib, ... }:

{
  imports = [
    ./configuration.nix
    ../../presets/system/common
    ../../presets/system/home-manager
    ../../presets/nixos/common
    ../../presets/nixos/desktop
    ../../presets/nixos/efi
    ../../presets/system/yubikey-agenix-rekey
  ];

  local.server.media.enable = true;

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
    };

  };

}
