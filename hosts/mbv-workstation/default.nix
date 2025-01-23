{ mod, pkgs, ... }:

{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    (mod "system/nixos/server")
    (mod "system/nixos/client")
    ./overclocking.nix
  ];

  local = {
    # This machine is already plenty fast, let's save some complication
    builder.enableRemoteBuilders = false;
  };

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
      # Should really be "cuda", but we currently get a collision.
      # I think it's related to the 'fixme' in: https://github.com/NixOS/nixpkgs/blob/bad6d5d22e7c6502d147f19b20bbbf759c5ee558/pkgs/tools/misc/ollama/default.nix#L27
      # acceleration = false;
      # The default, repeated for documentation
      # listenAddress = "0.0.0.0:11434";
      # host = "0.0.0.0";
      # port = "11434";
      models = "/var/lib/ollama/models";
      home = "/var/lib/ollama";
    };
  };
  local.restic.exclude = [ "/var/lib/ollama/models" ];
}
