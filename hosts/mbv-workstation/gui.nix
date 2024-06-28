{
  config,
  lib,
  pkgs,
  ...
}:

{
  programs = {
    # Could also try hyprland?
    sway.enable = true;
    waybar.enable = true;
    nm-applet.enable = true;
    spacefm.enable = true;
    firefox.enable = true;
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      # extest.enable = true; # Maybe useful for controllers?
    };

    tuxclocker = {
      enable = true;
      enableAMD = true;
    };
  };
}
