{ moduleCollections, pkgs, ... }:

{
  imports = [
    ./configuration.nix
    moduleCollections.services.media-server
  ]
  ++ moduleCollections.base-nixos
  ++ moduleCollections.nixos-server;

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
    displayManager.gdm = {
      enable = true;
      autoSuspend = false;
    };
  };

}
