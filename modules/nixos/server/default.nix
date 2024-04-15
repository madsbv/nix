{
  flake-root,
  config,
  lib,
  flake-inputs,
  ...
}:

let
  modules = flake-root + "/modules";
  # A user to use as manual SSH target. Can use sudo.
  cfg = config.local.server;
in
{
  imports = [
    flake-inputs.home-manager.nixosModules.home-manager
    flake-inputs.agenix.nixosModules.default
    flake-inputs.agenix-rekey.nixosModules.default
    flake-inputs.impermanence.nixosModules.impermanence
    flake-inputs.disko.nixosModules.disko
    (modules + "/shared") # modules/shared/default.nix
    (modules + "/shared/secrets/server.nix")
    (modules + "/nixos/restic.nix")
  ];
  options.local.server = {
    user = lib.mkOption { default = "mvilladsen"; };
    hostname = lib.mkOption { default = ""; };
    timezone = lib.mkOption { default = "Europe/Amsterdam"; };
  };
  config = {

    local.keys = {
      enable = true;
      enable_authorized_access = true;
      authorized_user = cfg.user;
    };

    system.autoUpgrade = {
      enable = true;
      flake = "github:madsbv/nix";
      persistent = true;
      allowReboot = true;
    };

    networking = {
      # hostId is set in configuration.nix
      hostName = cfg.hostname; # Define your hostname.
      firewall = {
        # Allow PMTU / DHCP
        allowPing = true;
        # Keep dmesg/journalctl -k output readable by NOT logging
        # each refused connection on the open internet.
        logRefusedConnections = lib.mkDefault false;
      };
      networkmanager.enable = true;
      # Use networkd instead of the pile of shell scripts
      useNetworkd = true;
      useDHCP = false;
      nameservers = [
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

    # Select internationalisation properties.
    i18n.defaultLocale = "en_US.UTF-8";
    console = {
      font = "Lat2-Terminus16";
      keyMap = "us";
    };

    # Set your time zone.
    time.timeZone = cfg.timezone;

    hardware.enableRedistributableFirmware = true;

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
      git.enable = true;

      # Conflicts with nix-index
      command-not-found.enable = false;
      zsh.syntaxHighlighting = {
        enable = true;
        highlighters = [
          "main"
          "brackets"
        ];
      };

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

    # Generic impermanence definitions for servers
    environment.persistence."/nix/persist" = {
      hideMounts = true;
      directories = [
        "/etc/nixos"
        "/etc/ssh" # We need the entire directory so we can set neededForBoot
        "/var/log"
        "/var/lib"
        # Restic basically needs its cache to be able to run in a reasonable amount of time
        "/var/cache/restic-backups-persist"
      ];
      files = [ "/etc/machine-id" ];
    };
    fileSystems = {
      # I don't know how many of these we actually need
      # "/".neededForBoot = true;
      # "/nix".neededForBoot = true;
      "/nix/persist".neededForBoot = true;
      # "/nix/persist/home".neededForBoot = true;
      "/etc/ssh".neededForBoot = true;
    };

    users = {
      # To enable local login, set `users.users.root.initialHashedPassword`
      # You can get the hash of a given password with `mkpasswd -m SHA-512`
      mutableUsers = false;
      users = {
        ${cfg.user} = {
          isNormalUser = true;
          extraGroups = [
            "wheel"
            "networkmanager"
          ];
          initialHashedPassword = "$6$qLCSEZb7i07pNwf4$QogfJ3DbSqtwrI29Uoe0jlehHKn.A62w2N3E5ZqQIhWPQvdeUBR8DcMgTv9CUpLKSIisjOZChfbDQo9ycJS9f.";
        };
      };
    };
    local.ssh-clients.users = [ cfg.user ];
    security.sudo = {
      execWheelOnly = true;
      extraConfig = ''
        Defaults lecture = never
      '';
    };
  };
}
