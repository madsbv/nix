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
    (mod "system/nixos/server")
    (mod "system/nixos/client")
    ./overclocking.nix
  ];

  system.autoUpgrade.allowReboot = lib.mkForce false;

  users.users = {
    root.openssh.authorizedKeys.keys = [
      # Enables running deploy-rs for localhost. Normally Tailscale would allow user on a client to access root anywhere, but Tailscale does not manage ssh to localhost.
      # https://github.com/tailscale/tailscale/issues/11097
      (builtins.readFile "${flake-root}/pubkeys/ssh/id_ed25519.mbv-workstation.mvilladsen.pub")
    ];
    mvilladsen.extraGroups = [ "gamemode" "adbusers"];
  };

  nixpkgs.config = {
    rocmSupport = true;
  };

  virtualisation = {
    docker.enable = true;
    podman.enable = true;
  };

  environment.systemPackages = with pkgs; [
    protonup-qt
    mangohud
    docker
    podman
    minikube
    kubectl
  ];

  programs = {
    adb.enable = true;
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

    tuxclocker.enable = true;

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

    ollama = {
      enable = true;
      acceleration = "rocm";
      ## Setting to force ollama to use GPU
      rocmOverrideGfx = "11.0.1";

      # The default, repeated for documentation
      # listenAddress = "0.0.0.0:11434";
      # host = "0.0.0.0";
      # port = "11434";
      home = "/var/lib/ollama";
      models = "/var/lib/ollama/models";
      loadModels = [
        "deepseek-r1:14b"
        "qwen2.5-coder:14b-instruct-q6_K"
        "qwen2.5:14b"
      ];
      environmentVariables = {
        OLLAMA_KEEP_ALIVE = "30m";
        OLLAMA_LOAD_TIMEOUT = "30m";
        OLLAMA_FLASH_ATTENTION = "1";
      };
    };
  };
  local.restic.exclude = [ "/var/lib/ollama/models" ];
  environment.persistence."/nix/persist".directories = [ "/var/lib/ollama/models" ];
}
