{
  mod,
  pkgs,
  flake-root,
  lib,
  ...
}:

{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    # Use mod helper for now, until we can fully migrate to exports
    (mod "system/nixos/server")
    (mod "system/nixos/client")
    ./overclocking.nix
    ./extrauser.nix
  ];

  system.autoUpgrade = {
    allowReboot = lib.mkForce false;
    flake = "/etc/nixos/nix";
    flags = [
      "--update-input"
      "nixpkgs"
      "--commit-lock-file"
    ];
  };

  users.users = {
    root.openssh.authorizedKeys.keys = [
      # Enables running deploy-rs for localhost. Normally Tailscale would allow user on a client to access root anywhere, but Tailscale does not manage ssh to localhost.
      # https://github.com/tailscale/tailscale/issues/11097
      (builtins.readFile "${flake-root}/pubkeys/ssh/id_ed25519.mbv-workstation.mvilladsen.pub")
    ];
    mvilladsen.extraGroups = [
      "libvirtd"
      "gamemode"
      "adbusers"
    ];
  };

  nixpkgs.config = {
    rocmSupport = true;
    # TODO: Figure out reverse dependency issue and remove this
    permittedInsecurePackages = [
      "electron-39.8.10"
    ];
  };

  virtualisation = {
    docker.enable = true;
    podman.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        # ovmf = {
        #   enable = true;
        #   packages = [ pkgs.OVMFFull.fd ];
        # };
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    spiceUSBRedirection.enable = true;
  };

  environment.systemPackages = with pkgs; [
    virt-manager
    virt-viewer
    spice
    spice-gtk
    spice-protocol
    virtio-win
    win-spice

    protonup-qt
    mangohud
    docker
    podman
    minikube
    kubectl
  ];

  programs = {
    virt-manager.enable = true;
    dconf.enable = true;
    steam = {
      enable = true;
      package = pkgs.steam.override {
        extraPkgs =
          pkgs: with pkgs; [
            gamemode
            python3
            # additional packages...
            # e.g. some games require python3
          ];
      };
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      # extest.enable = true; # Maybe useful for controllers?
    };

    tuxclocker.enable = false;

    # TODO: Run Steam with gamemoderun automatically--probably a wrapper script, but how to register as application with Awesomewm program launcher?
    gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
          inhibit_screensaver = 1;
          disable_splitlock = 1;
        };

        # Warning: GPU optimisations have the potential to damage hardware
        # gpu = {
        #   apply_gpu_optimisations = "accept-responsibility";
        #   gpu_device = 1;
        #   amd_performance_level = "high";
        # };

        cpu = {
          pin_cores = "yes";
        };

        custom = {
          start = "''${pkgs.libnotify}/bin/notify-send 'GameMode started'";
          end = "''${pkgs.libnotify}/bin/notify-send 'GameMode ended'";
        };
      };
    };
  };

  services = {
    # Provides blueman-applet and blueman-manager for managing bluetooth connections
    blueman.enable = true;
    printing = {
      enable = true;
      drivers = with pkgs; [
        cups-filters
        canon-capt         # patched overlay with LBP6300 support
      ];
    };
    avahi = {
      enable = true;       # mDNS/DNS-SD for network printer discovery
      nssmdns4 = true;
      openFirewall = true;
    };
  };
  # Uncomment after rebuild and verifying `lpinfo -v` shows the USB printer:
  # hardware.printers = {
  #   ensurePrinters = [
  #     {
  #       name = "Canon_LBP6300dn";
  #       location = "Home Office";
  #       # Get the exact deviceUri from `lpinfo -v` output, e.g.:
  #       #   direct usb://Canon/LBP6300dn?serial=XXXXXXXXXXXX
  #       deviceUri = "usb://Canon/LBP6300dn?serial=XXXXXXXXXXXX";
  #       model = "canon/CanonLBP-6300-6300dn.ppd";
  #       ppdOptions = {
  #         PageSize = "A4";
  #       };
  #     }
  #   ];
  #   ensureDefaultPrinter = "Canon_LBP6300dn";
  # };
  local.restic.exclude = [
    "/nix/persist/var/lib/private/ollama"
    "/nix/persist/var/lib/libvirt/images"
    "/nix/persist/home/mvilladsen/.local/share/Steam"
    "/nix/persist/home/mvilladsen/Downloads"
    "/nix/persist/home/mvilladsen/.cache"
  ];
  environment.persistence."/nix/persist".directories = [ "/var/lib/private/ollama/models" ];
}
