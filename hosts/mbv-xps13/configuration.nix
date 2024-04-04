{ config, ... }:

{
  imports = [ ./hardware-configuration.nix ./disko.nix ./persist.nix ];

  # Don't suspend on lid close
  services.logind = {
    lidSwitch = "ignore";
    lidSwitchDocked = "ignore";
    lidSwitchExternalPower = "ignore";
    suspendKey = "ignore";
  };

  networking = {
    hostId = "8425e349";
    networkmanager = {
      enable = true; # Easiest to use and most
      appendNameservers = [
        # Quad9 primary and secondary, including ipv6
        "9.9.9.9"
        "149.112.112.112"
        "2620:fe::fe"
        "2620:fe::9"
        # Cloudflare 1.1.1.1 malware blocking, primary and secondary, including ipv6
        "1.1.1.2"
        "1.0.0.2"
        "2606:4700:4700::1112"
        "2606:4700:4700::1002"
      ];
    };
  };
  # Networkmanager has the option ensureProfile which could handle this in a nicer way, but that would leak secrets.
  # https://nixos.org/manual/nixos/stable/options#opt-networking.networkmanager.ensureProfiles.profiles
  environment.etc."NetworkManager/system-connections/home-wifi.nmconnection".source =
    config.age.secrets.home-wifi-nm.path;

  nixpkgs.hostPlatform = "x86_64-linux";
  # Use the systemd-boot EFI boot loader.
  boot.loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  hardware.enableRedistributableFirmware = true;

  # This option defines the first version of NixOS you have installed on this particular machine,
  # and is used to maintain compatibility with application data (e.g. databases) created on older NixOS versions.
  #
  # Most users should NEVER change this value after the initial install, for any reason,
  # even if you've upgraded your system to a new NixOS release.
  #
  # This value does NOT affect the Nixpkgs version your packages and OS are pulled from,
  # so changing it will NOT upgrade your system.
  #
  # This value being lower than the current NixOS release does NOT mean your system is
  # out of date, out of support, or vulnerable.
  #
  # Do NOT change this value unless you have manually inspected all the changes it would make to your configuration,
  # and migrated your data accordingly.
  #
  # For more information, see `man configuration.nix` or https://nixos.org/manual/nixos/stable/options#opt-system.stateVersion .
  system.stateVersion = "23.11"; # Did you read the comment?
}
