{ pkgs, mod, ... }:

{
  imports = [
    (mod "system/common/client")
    (mod "system/nixos/common")
    ./dropbox.nix
    ./yubikey.nix
  ];

  home-manager.sharedModules = [ (mod "home-manager/nixos/client") ];

  local.emacs.package = pkgs.emacs;

  # No longer exists on nix-darwin
  fonts.fontDir.enable = true;

  services = {
    xserver = {
      enable = true;
      # Equivalent to `xset r rate 200 40`
      autoRepeatDelay = 200;
      autoRepeatInterval = 40;
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
    firefox.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-volman
        thunar-dropbox-plugin
        thunar-archive-plugin
      ];
    };
  };

  environment.systemPackages = with pkgs; [
    pavucontrol
    pwvucontrol
    bitwarden-desktop
  ];
}
