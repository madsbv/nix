# Use pipewire instead of PulseAudio. See https://wiki.nixos.org/wiki/PipeWire
{ lib, config, ... }:
{
  security.rtkit.enable = lib.mkDefault config.services.pipewire.enable;
  services = {
    pipewire = {
      enable = lib.mkDefault true;
      alsa.enable = lib.mkDefault true;
      pulse.enable = lib.mkDefault true;
    };
    printing = {
      enable = true;
    };
    # Provides blueman-applet and blueman-manager for managing bluetooth connections
    blueman.enable = true;
  };
  fonts.fontDir.enable = true;

  xdg = {
    portal = {
      enable = true;
      config = {
        common = {
          default = [ "gtk" ];
        };
      };
      extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    };
  };

}
