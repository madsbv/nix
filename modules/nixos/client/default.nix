{ lib, pkgs, ... }:

{
  services = {
    xserver = {
      enable = true;
      displayManager.lightdm = {
        enable = true;
      };
      # desktopManager.cinnamon = {
      #   enable = true;
      # };
      windowManager.awesome = {
        enable = true;
        luaModules = [ ];
      };
    };
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };
  };

  sound.enable = lib.mkForce false;

  # Recommended by https://nixos.wiki/wiki/PipeWire
  security.rtkit.enable = true;

  programs = {
    nm-applet.enable = true;
    spacefm.enable = true;
    firefox.enable = true;
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    pwvucontrol
  ];
}
