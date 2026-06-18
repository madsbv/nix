{
  pkgs,
  flake-root,
  lib,
  ...
}:

{
  imports = [
    ./configuration.nix
    ./overclocking.nix
    # ./extrauser.nix
    ../../presets/system/common
    ../../presets/system/home-manager
    ../../presets/system/yubikey-agenix-rekey
    ../../presets/nixos/common
    ../../presets/nixos/desktop
    ../../presets/nixos/efi
    ../../presets/nixos/awesomewm
  ];

  local = {
    laptop.enable = true;
    wifi.enable = true;
    yubikey.enable = true;
  };

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
}
