{
  inputs,
  config,
  lib,
  pkgs,
  systemModules,
  flake-root,
  ...
}:

{
  imports = [ systemModules.register-flake ];

  srvos.flake = flake-root;

  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  # nix-darwin has its own mechanism for this
  nix = {
    channel.enable = false;
    registry = lib.mkIf pkgs.stdenv.isLinux (
      (lib.mapAttrs (_: flake: { inherit flake; })) ((lib.filterAttrs (_: lib.isType "flake")) inputs)
    );
    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = lib.mkIf pkgs.stdenv.isLinux [ "/etc/nix/path" ];
    package = pkgs.nixVersions.latest;

    gc =
      with lib;
      mkMerge [
        (
          if pkgs.stdenv.isDarwin then
            {
              # Nix-darwin
              interval = {
                Weekday = 0;
                Hour = 2;
                Minute = 0;
              };
            }
          else
            {
              # NixOS
              dates = "weekly";
            }
        )
        {
          automatic = true;
          options = "--delete-older-than 30d";
        }
      ];

    # De-duplicate store paths using hardlinks except in containers
    optimise.automatic = lib.mkDefault (!config.boot.isContainer);

    settings = {
      # Default is 67108864, which is 64MiB in bytes
      download-buffer-size = 268435456; # 256 MiB

      # sandbox = true or relaxed has problems on Darwin (see https://github.com/NixOS/nix/issues/4119)
      # If you get trapped by this, manually edit /etc/nix/nix.conf to set sandbox = false, kill nix-daemon, then try again (optionally with `--option sandbox false' added as well).
      sandbox = if pkgs.stdenv.isDarwin then false else true;
      # May need to add `builder` to this list.
      trusted-users = [
        "root"
        "@admin"
        "@wheel"
        "@builders"
      ];

      # Reduce copying over SSH
      builders-use-substitutes = true;
      # Fallback quickly if substituters are not available
      fallback = true;
      connect-timeout = 3;

      keep-going = true;

      log-lines = lib.mkDefault 50;
      show-trace = true;

      # Units: bytes
      max-free = lib.mkDefault (10 * 1024 * 1024 * 1024); # 10 GiB
      min-free = lib.mkDefault (1 * 1024 * 1024 * 1024); # 1 GiB

      warn-dirty = false;
      experimental-features = [
        "nix-command"
        "flakes"
        "ca-derivations"
        "fetch-closure"
        "recursive-nix"
        "blake3-hashes"
      ];
      substituters = [
        "https://nix-community.cachix.org/"
        "https://cache.garnix.io"
        "https://numtide.cachix.org"
      ];
      trusted-public-keys = [
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
        "cache.garnix.io:CTFPyKSLcx5RMJKfLo5EEPUObbA78b0YQ2DTCJXqr9g="
        "numtide.cachix.org-1:2ps1kLBUWjxIneOy1Ik6cQjb41X0iXVXeHigGmycPPE="
      ];
    };
    distributedBuilds = true;
  };
}
