{ lib, ... }:

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
  };
  services.pipewire.enable = true;
  sound.enable = lib.mkForce false;
  programs = {
    # Could also try hyprland?
    # sway.enable = true;
    # waybar.enable = true;
    #
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
