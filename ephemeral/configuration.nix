{ system, flake-root, inputs, pkgs, config, lib, ... }:

let
  client_keys =
    [ (builtins.readFile "${flake-root}/pubkeys/clients/mbv-mba.pub") ];
in {
  imports = [ ./hardware-configuration.nix ./disko.nix ];

  nixpkgs.hostPlatform = lib.mkForce system;
  boot = {
    initrd.network = {
      ssh.enable = true;
      ssh.authorizedKeys = client_keys;
    };
    # Use the systemd-boot EFI boot loader.
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
  };

  networking = {
    hostId = "1f81d600";
    hostName = "ephemeral"; # Define your hostname.
    # Easiest to use and most distros use this by default.
    # networkmanager.enable = true;
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
      tmux
      networkmanager
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
        highlighters = [ "main" "brackets" ];
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
  users.users.root.openssh.authorizedKeys.keys = client_keys;

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