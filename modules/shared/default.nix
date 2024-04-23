{
  flake-inputs,
  flake-root,
  hostname,
  nodes,
  lib,
  config,
  pkgs,
  base16,
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
    environment.shellAliases = {
      # TODO: Make these point to the corresponding packages, instead of just string aliases?
      j = "just";
      ls = "eza --binary --header --git --git-repos --all";
      # TODO: Themeing?
      cat = "bat";
      cd = "z";
    };

    local = {
      builder = {
        enableLocalBuilder = true;
        enableRemoteBuilders = true;
        # Enable all servers other than this one as remote builders
        remoteBuilders_x86-64 = builtins.filter (host: host != hostname) nodes.servers;
      };
      neovim.enable = true;
      keys = {
        enable = true;
      };
    };

    home-manager = lib.mkIf config.local.hm.enable {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = flake-inputs // {
        inherit hostname flake-root mod;
      };
      sharedModules = [
        (
          { ... }:
          {
            # Currently used for Kitty and Alacritty only
            imports = [ base16.homeManagerModule ];
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
    nix = {
      registry = (lib.mapAttrs (_: flake: { inherit flake; })) (
        (lib.filterAttrs (_: lib.isType "flake")) flake-inputs
      );
      # This will additionally add your inputs to the system's legacy channels
      # Making legacy nix commands consistent as well, awesome!
      nixPath = [ "/etc/nix/path" ];
      package = pkgs.nixUnstable;

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
      settings = {
        auto-optimise-store = true;
        # sandbox = true or relaxed has problems on Darwin (see https://github.com/NixOS/nix/issues/4119)
        # If you get trapped by this, manually edit /etc/nix/nix.conf to set sandbox = false, kill nix-daemon, then try again (optionally with `--option sandbox false' added as well).
        sandbox = if pkgs.stdenv.isDarwin then false else true;
        log-lines = lib.mkDefault 25;
        # May need to add `builder` to this list.
        trusted-users = [
          "root"
          "@admin"
          "@wheel"
        ];

        # Reduce copying over SSH
        builders-use-substitutes = true;
        # Fallback quickly if substituters are not available
        connect-timeout = 5;
      };
      distributedBuilds = true;

      extraOptions = ''
        experimental-features = nix-command flakes repl-flake ca-derivations
        warn-dirty = false
        !include ${config.age.secrets.github-api-key-minimal.path}
      '';
    };

    nixpkgs = {
      config = {
        # Required for Zoom
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
      etc = lib.mapAttrs' (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      }) config.nix.registry;
      systemPackages = import ../../modules/shared/system-packages.nix { inherit pkgs; };
    };
  };
}
