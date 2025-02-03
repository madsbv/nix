{
  mod,
  pkgs,
  flake-root,
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

  users.users.root.openssh.authorizedKeys.keys = [
    # Enables running deploy-rs for localhost. Normally Tailscale would allow user on a client to access root anywhere, but Tailscale does not manage ssh to localhost.
    # https://github.com/tailscale/tailscale/issues/11097
    (builtins.readFile "${flake-root}/pubkeys/ssh/id_ed25519.mbv-workstation.mvilladsen.pub")
  ];

  nixpkgs.config = {
    rocmSupport = true;
  };

  environment.systemPackages = with pkgs; [
    protonup-qt
    mangohud
  ];

  programs = {
    steam = {
      enable = true;
      remotePlay.openFirewall = true;
      localNetworkGameTransfers.openFirewall = true;
      gamescopeSession.enable = true;
      # extest.enable = true; # Maybe useful for controllers?
    };

    tuxclocker = {
      enable = true;
      enableAMD = true;
    };

    gamemode.enable = true;
    gamescope = {
      enable = true;
      capSysNice = true;

    };
  };

  services = {
    # Provides blueman-applet and blueman-manager for managing bluetooth connections
    blueman.enable = true;

    # Daemon to monitor APC UPS'. The default settings autodetect connections to the UPS over USB, and automatically shut down the computer if the UPS falls below 50% or 5 minutes of battery time.
    apcupsd.enable = true;

    ollama = {
      enable = true;
      acceleration = "rocm";
      ## Setting to force ollama to use GPU
      rocmOverrideGfx = "10.1.1";

      # The default, repeated for documentation
      # listenAddress = "0.0.0.0:11434";
      # host = "0.0.0.0";
      # port = "11434";
      home = "/var/lib/ollama";
      models = "/var/lib/ollama/models";
      loadModels = [
        "deepseek-r1:14b"
        "qwen2.5-coder:14b-instruct-q6_K"
      ];
      environmentVariables = {
        OLLAMA_KEEP_ALIVE = "10m";
        OLLAMA_LOAD_TIMEOUT = "15m";
        OLLAMA_FLASH_ATTENTION = "1";
      };
    };
  };
  local.restic.exclude = [ "/var/lib/ollama/models" ];
  environment.persistence."/nix/persist".directories = [ "/var/lib/ollama/models" ];
}
