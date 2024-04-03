{ user, flake-root, config, hostname, lib, ... }:

let
  client_keys =
    [ (builtins.readFile "${flake-root}/pubkeys/ssh/id_ed25519.pub.mbv-mba") ];
  modules = flake-root + "/modules/shared";
in {
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    # TODO: Consider factoring a bunch of this out into a module
    ./configuration.nix
    (modules + "/") # modules/shared/default.nix
  ];

  srvos.flake = flake-root;

  system.autoUpgrade = {
    enable = true;
    flake = "github:madsbv/nix";
    persistent = true;
    allowReboot = true;
  };

  networking = {
    hostName = hostname; # Define your hostname.
    # Easiest to use and most distros use this by default.
    # networkmanager.enable = true;
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

  systemd = {
    # The notion of "online" is a broken concept
    # https://github.com/systemd/systemd/blob/e1b45a756f71deac8c1aa9a008bd0dab47f64777/NEWS#L13
    network.wait-online.enable = false;
    services = {
      NetworkManager-wait-online.enable = false;

      # FIXME: Maybe upstream?
      # Do not take down the network for too long when upgrading,
      # This also prevents failures of services that are restarted instead of stopped.
      # It will use `systemctl restart` rather than stopping it with `systemctl stop`
      # followed by a delayed `systemctl start`.
      systemd-networkd.stopIfChanged = false;
      # Services that are only restarted might be not able to resolve when resolved is stopped before
      systemd-resolved.stopIfChanged = false;

      # Make builds to be more likely killed than important services.
      # 100 is the default for user slices and 500 is systemd-coredumpd@
      # We rather want a build to be killed than our precious user sessions as builds can be easily restarted.
      nix-daemon.serviceConfig.OOMScoreAdjust = lib.mkDefault 250;
    };
  };

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

  services = {
    tailscale = {
      enable = true;
      authKeyFile = config.age.secrets.tailscale-server-authkey.path;
      extraUpFlags = [ "--ssh" ];
    };
    openssh = {
      enable = true;
      settings = {
        X11Forwarding = false;
        KbdInteractiveAuthentication = false;
        PasswordAuthentication = false;
      };
    };

    zfs = lib.mkIf config.boot.zfs.enabled {
      autoSnapshot.enable = true;
      # autoSnapshot by default keeps hourly snapshots for whole day, daily snapshots for a week, and so on, up to monthly snapshots for a year. That might be a bit much for disk storage reasons.
      autoSnapshot.monthly = 3;
      autoScrub.enable = true;
      # zfs enables periodic TRIM by default
    };
  };

  # Mostly for SSH setup to satisfy Github, but might as well have a comfortable environment
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    users.${user} = { imports = [ (modules + "/home-manager.nix") ]; };
  };

  users = {
    # To enable local login, set `users.users.root.initialHashedPassword`
    # You can get the hash of a given password with `mkpasswd -m SHA-512`
    mutableUsers = false;
    users = {
      # TODO: Still missing some key management pieces, since Github apparently wants an authorized key for something.
      ${user} = {
        isNormalUser = true;
        extraGroups = [ "wheel" "networkmanager" ];
        openssh.authorizedKeys.keys = client_keys;
        initialHashedPassword =
          "$6$qLCSEZb7i07pNwf4$QogfJ3DbSqtwrI29Uoe0jlehHKn.A62w2N3E5ZqQIhWPQvdeUBR8DcMgTv9CUpLKSIisjOZChfbDQo9ycJS9f.";
      };
    };
  };
  boot.initrd.network = {
    ssh.enable = true;
    ssh.authorizedKeys = client_keys;
  };
  security.sudo = {
    execWheelOnly = true;
    extraConfig = ''
      Defaults lecture = never
    '';
  };

}
