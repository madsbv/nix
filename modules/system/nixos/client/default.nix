{ pkgs, modules, ... }:

let
  user = "mvilladsen";
in
{
  # TODO: Really needs some refactoring to accomodate mbv-desktop as well.

  home-manager = {
    users.${user} = {
      imports = [ modules.home-manager.nixos-client ];
    };
    sharedModules = [ modules.home-manager.nixos-common ];
  };

  fonts.fontDir.enable = true;

  services = {
    xserver = {
      enable = true;
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
      windowManager.awesome = {
        enable = true;
        luaModules = [ ];
      };
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

  programs = {
    i3lock.enable = true;
    nm-applet.enable = true;
    thunar = {
      enable = true;
      plugins = with pkgs; [
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

    proton-vpn

    # Image viewers
    # geeqie # Depends on libsoup-2 which has vulnerability
    kdePackages.gwenview
    image-roll
    eog
  ];
}
