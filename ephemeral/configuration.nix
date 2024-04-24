{
  system,
  flake-inputs,
  pkgs,
  config,
  lib,
  mod,
  ...
}:

{
  imports = [
    ./hardware-configuration.nix
    ./disko.nix
    (mod "shared/keys.nix")
  ];

  local.keys = {
    enable = true;
    enable_authorized_access = true;
    authorized_user = "root";
  };

  nixpkgs.hostPlatform = lib.mkForce system;
  boot = {
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostId = "1f81d600";
    hostName = "ephemeral"; # Define your hostname.
    wireless.enable = false;
    networkmanager = {
      enable = true;
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
    firewall = {
      # Allow PMTU / DHCP
      allowPing = true;
      # Keep dmesg/journalctl -k output readable by NOT logging
      # each refused connection on the open internet.
      logRefusedConnections = lib.mkDefault false;
    };
    # Use networkd instead of the pile of shell scripts
    useNetworkd = true;
    useDHCP = false;
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
    registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
      (lib.filterAttrs (_: lib.isType "flake")) flake-inputs
    );
    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = [ "/etc/nix/path" ];
    settings = {
      experimental-features = "nix-command flakes";
      auto-optimise-store = true;
    };
  };

  environment = {
    etc = lib.mapAttrs' (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    }) config.nix.registry;
    systemPackages = with pkgs; [
      coreutils
      inetutils
      killall
      fd
      gdu
      ripgrep
      tree
      zellij
    ];
  };

  # To enable local login, set `users.users.root.initialHashedPassword`
  # You can get the hash of a given password with `mkpasswd -m SHA-512`
  users.mutableUsers = false;

  programs = {
    zsh = {
      enable = true;
      enableCompletion = true;
      syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
        ];
      };
    };
    git.enable = true;
    neovim = {
      enable = true;
      vimAlias = true;
      viAlias = true;
      defaultEditor = true;
    };
  };

  # NOTE: In the committed git history, the file ./tailscale-auth should always be empty.
  # To inject the ephemeral tailscale authentication key at build time, we use a Just recipe to decrypt the key stored in secrets/tailscale, put it in ./tailscale-auth temporarily, build the image, and then clear ./tailscale-auth again.
  # THIS HAS SECURITY IMPLICATIONS.
  # If you try to go through this workflow manually and make a mistake, the tailscale authkey can end up in git. The authkey WILL be stored in the world-readable nix store.
  # This is acceptable to me because an attacker with local storage access can read my host key anyway and decrypt the key directly; and if the authkey gets leaked in git, I can revoke it in the tailscale management console. Furthermore, my Tailscale ACLs are set up to allow machines authenticated with this key to receive connections, but never to establish connections to other machines on my tailnet, so this key does not grant access to any other machines.
  # TODO: Can Disko be used to do this better? See https://github.com/nix-community/disko/blob/master/docs/reference.md
  # There's options to copy files to the VM.
  services = {
    tailscale = {
      enable = true;
      authKeyFile = ./tailscale-auth;
      extraUpFlags = [ "--ssh" ];
    };
    openssh.enable = true;
  };

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
