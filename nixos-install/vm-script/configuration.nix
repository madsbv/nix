# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ inputs, config, lib, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./hardware-configuration.nix
    ./persist.nix
  ];

  boot = {
    initrd.network.ssh.authorizedKeys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICw4EOQ09b7tm06Ulct4Lm44SEEqmx8DcvgRX+ZXofX/"
    ];
    initrd.network.ssh.enable = true;
    # Use the systemd-boot EFI boot loader.
    loader.systemd-enable = true;
    loader.efi.canTouchEfiVariables = true;
    zfs.devNodes =
      "/dev/disk/by-partlabel"; # But this might be: https://discourse.nixos.org/t/21-05-zfs-root-install-cant-import-pool-on-boot/13652/6
  };

  fileSystems = {
    "/".options = [ "defaults" "size=2G" "mode=755" ];
    "/nix".neededForBoot = true;
    "/nix/persist".neededForBoot = true;
    "/nix/persist/home".neededForBoot = true;
    "/boot".options = [ "umask=0077" ];
  };

  networking = {
    hostId = "1f81d600";
    hostName = "nixos-guest"; # Define your hostname.
    # networkmanager.enable = true;  # Easiest to use and most distros use this by default.
  };

  # Set your time zone.
  time.timeZone = "Europe/Amsterdam";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";
  console = {
    font = "Lat2-Terminus16";
    keyMap = "us";
  };

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix = {
    registry = (lib.mapAttrs (_: flake: { inherit flake; }))
      ((lib.filterAttrs (_: lib.isType "flake")) inputs);
    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = [ "/etc/nix/path" ];
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  environment.etc = lib.mapAttrs' (name: value: {
    name = "nix/path/${name}";
    value.source = value.flake;
  }) config.registry;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  # users.users.alice = {
  #   isNormalUser = true;
  #   extraGroups = [ "wheel" ]; # Enable ‘sudo’ for the user.
  #   packages = with pkgs; [
  #     firefox
  #     tree
  #   ];
  # };

  # To enable local login, set `users.users.root.initialHashedPassword`
  # You can get the hash of a given password with `mkpasswd -m SHA-512`
  users.mutableUsers = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  # environment.systemPackages = with pkgs; [
  #   vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
  #   wget
  # ];

  programs = {
    ssh.enable = true;
    git.enable = true;
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    };
  };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  services.openssh.enable = true;
  users.users.root.openssh.authorizedKeys.keys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAICw4EOQ09b7tm06Ulct4Lm44SEEqmx8DcvgRX+ZXofX/"
  ];

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
