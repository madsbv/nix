{ agenix, agenix-rekey, flake-inputs, fenix, lib, config, pkgs, ... }:

let emacsOverlaySha256 = "06413w510jmld20i4lik9b36cfafm501864yq8k4vxl5r4hn0j0h";
in {
  # This will add each flake input as a registry
  # To make nix3 commands consistent with your flake
  nix = {
    registry = (lib.mapAttrs (_: flake: { inherit flake; }))
      ((lib.filterAttrs (_: lib.isType "flake")) flake-inputs);
    # This will additionally add your inputs to the system's legacy channels
    # Making legacy nix commands consistent as well, awesome!
    nixPath = [ "/etc/nix/path" ];
    package = pkgs.nixUnstable;

    gc = {
      user = "root";
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
      options = "--delete-older-than 30d";
    };
    settings = {
      auto-optimise-store = true;
      sandbox = lib.mkDefault true;
    };

    extraOptions = ''
      experimental-features = nix-command flakes repl-flake
    '';
  };

  nixpkgs = {
    config = {
      # Required for Zoom
      allowUnfree = true;
      allowBroken = false;
      allowInsecure = false;
      allowUnsupportedSystem = false;
    };
    overlays =
      # Apply each overlay found in the /overlays directory
      let path = ../../overlays;
      in with builtins;
      map (n: import (path + ("/" + n))) (filter (n:
        match ".*\\.nix" n != null
        || pathExists (path + ("/" + n + "/default.nix")))
        (attrNames (readDir path))) ++ [ fenix.overlays.default ];
    # ++ [ agenix-rekey.overlays.default ];
  };

  environment = {
    etc = lib.mapAttrs' (name: value: {
      name = "nix/path/${name}";
      value.source = value.flake;
    }) config.nix.registry;
    systemPackages = [
      # agenix.packages."${pkgs.system}".default
      # TODO: Move this somewhere else, probably a free-standing module imported in either individual hosts or just in shared
      # NOTE: Provides rustc, cargo, rustfmt, clippy, from the nightly toolchain.
      # To get stable or beta toolchain, do ..darwin.stable.defaultToolchain, e.g., or to get the complete toolchain (including stuff like MIRI that I probably don't need) replace default.toolchain with complete.toolchain or latest.toolchain.
      # Can also get toolchains for specified targets, e.g. targets.wasm32-unknown-unknown.latest.toolchain
      fenix.packages."${pkgs.system}".latest.toolchain
    ] ++ (import ../../modules/shared/packages.nix { inherit pkgs; });
  };
}
