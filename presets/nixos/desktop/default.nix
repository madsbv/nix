# Use pipewire instead of PulseAudio. See https://wiki.nixos.org/wiki/PipeWire
{
  inputs,
  modules,
  nox,
  lib,
  config,
  pkgs,
  ...
}:
let
  user = "mvilladsen";
in
{
  home-manager = {
    users.${user} = {
      imports = [
        modules.home-manager.common-client
        modules.home-manager.dev-all
      ];
    };
    extraSpecialArgs = {
      inherit user inputs nox;
    };
  };
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
    xserver = {
      # Equivalent to `xset r rate 200 25`; xset takes repeat rate in hz, autoRepeatInterval is the interval in ms.
      autoRepeatDelay = 200;
      autoRepeatInterval = 40;
      xkb = {
        layout = "us";
        variant = "altgr-intl";
      };

      displayManager.lightdm = {
        enable = true;
      };
      # desktopManager.cinnamon = {
      #   enable = true;
      # };
    };
    protonmail-bridge = {
      enable = true;
      path = with pkgs; [ gnome-keyring ];
    };
    gnome.gnome-keyring.enable = true;
    # Image thumbnail service, for thunar
    tumbler.enable = true;
    # For thunar to support removable media and such
    gvfs.enable = true;
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
  programs = {
    i3lock.enable = true;
    nm-applet.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs.xfce; [
        thunar-volman
        thunar-dropbox-plugin
        thunar-archive-plugin
        thunar-media-tags-plugin
      ];
    };
    # xfce config manager, to enable saving thunar configuration
    xfconf.enable = true;
    # Some gnome-based software depends on dconf to store configuration settings
    dconf.enable = true;
  };

  environment.systemPackages = with pkgs; [
    dconf-editor
    pavucontrol
    pwvucontrol
    bitwarden-desktop

    protonvpn-gui

    # Image viewers
    # geeqie # Depends on libsoup-2 which has vulnerability
    kdePackages.gwenview
    image-roll
    eog
  ];

}
