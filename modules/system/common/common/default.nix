{
  inputs,
  flake-root,
  hostname,
  nodes,
  lib,
  config,
  pkgs,
  color-scheme,
  mod,
  ...
}:

{
  imports = [
    ./cachix
    ./srvos/upgrade-diff.nix
    ./srvos/terminfo.nix
    ./secrets
    ./keys.nix
    ./builder.nix
    (mod "editor")
    (mod "shell")
  ];

  options.local.hm.enable = lib.mkOption {
    default = true;
    description = "Whether to enable home-manager modules";
  };

  config = {
    local = {
      builder = {
        enableLocalBuilder = true;
        enableRemoteBuilders = true;
        # Enable all servers other than this one as remote builders
        # TODO: Figure out how to check which servers are online before trying to use them as build hosts, or reduce the timeout for ssh-ng connections.
        # remoteBuilders_x86-64 = builtins.filter (host: host != hostname) nodes.servers;
      };
      neovim.enable = true;
      keys = {
        enable = true;
      };
    };

    home-manager = lib.mkIf config.local.hm.enable {
      useGlobalPkgs = true;
      useUserPackages = true;
      backupFileExtension = "home-manager-backup";
      extraSpecialArgs = {
        inherit
          hostname
          flake-root
          mod
          inputs
          ;
      };
      sharedModules = [
        (
          { ... }:
          {
            # Currently used for Kitty and Alacritty only
            imports = [ inputs.base16.homeManagerModule ];
            scheme = color-scheme;
            xdg.enable = true;
            home = {
              stateVersion = "23.11";
              preferXdgDirectories = true;
            };
          }
        )
      ];
    };

    srvos.flake = flake-root;

    # This will add each flake input as a registry
    # To make nix3 commands consistent with your flake
    # nix-darwin has its own mechanism for this
    nix = {
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
                user = "root";
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

      optimise = {
        automatic = true;
      };

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
        ];

        # Reduce copying over SSH
        builders-use-substitutes = true;
        # Fallback quickly if substituters are not available
        fallback = true;
        connect-timeout = 3;

        keep-going = true;

        log-lines = lib.mkDefault 250;
        show-trace = true;

        warn-dirty = false;
        experimental-features = [
          "nix-command"
          "flakes"
          "ca-derivations"
        ];
      };
      distributedBuilds = true;

      extraOptions = ''
        !include ${config.age.secrets.github-api-key-minimal.path}
      '';
    };

    nixpkgs = {
      config = {
        # Required for Zoom, Furmark, mprime
        allowUnfree = true;
        allowBroken = false;
        # allowInsecure = false;
        allowUnsupportedSystem = false;
        warnUndeclaredOptions = true;
        # TODO: Try this out
        # contentAddressedByDefault = true;
      };
      overlays =
        # Apply each overlay found in the /overlays directory
        let
          path = flake-root + "/overlays";
        in
        with builtins;
        map (n: import (path + ("/" + n))) (
          filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
            attrNames (readDir path)
          )
        );
    };

    environment = {
      # nix-darwin has its own mechanism for this
      etc = lib.mkIf pkgs.stdenv.isLinux (
        lib.mapAttrs' (name: value: {
          name = "nix/path/${name}";
          value.source = value.flake;
        }) config.nix.registry
      );
      systemPackages = import ./system-packages.nix { inherit pkgs; };
    };
  };
}
