{ pkgs, mod, ... }:

let
  user = "mvilladsen";
in
{
  imports = [
    (mod "system/common/client")
    (mod "system/nixos/common")
    ./yubikey.nix
  ];

  # TODO: Really needs some refactoring to accomodate mbv-desktop as well.

  home-manager = {
    users.${user} = {
      imports = [ (mod "home-manager/nixos/client") ];
    };
    sharedModules = [ (mod "home-manager/nixos/common") ];
  };

  # local.emacs.package = pkgs.emacs;

  # No longer exists on nix-darwin
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
    pipewire = {
      enable = true;
      alsa.enable = true;
      pulse.enable = true;
    };

    protonmail-bridge = {
      enable = true;
      path = with pkgs; [ gnome-keyring ];
    };
    gnome.gnome-keyring.enable = true;
    # Image thumbnail service, for thunar
    tumbler.enable = true;
  };

  # Recommended by https://nixos.wiki/wiki/PipeWire
  security.rtkit.enable = true;

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
