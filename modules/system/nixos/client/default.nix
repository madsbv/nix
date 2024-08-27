{ pkgs, mod, ... }:

{
  imports = [
    (mod "system/common/client")
    (mod "system/nixos/common")
  ];

  home-manager.sharedModules = [ (mod "home-manager/nixos/client") ];

  local.emacs.package = pkgs.emacs;

  # No longer exists on nix-darwin
  fonts.fontDir.enable = true;

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
    bitwarden-desktop
    dropbox
    dropbox-cli
  ];
}
