{
  lib,
  config,
  pkgs,
  fenix,
  ...
}:

{
  home-manager.sharedModules = lib.mkIf config.local.hm.enable [
    {
      programs.bacon = {
        enable = true;
        settings = { };
      };
    }
  ];

  nixpkgs.overlays = [ fenix.overlays.default ];
  environment.systemPackages = with pkgs; [
    # NOTE: Provides rustc, cargo, rustfmt, clippy, from the nightly toolchain.
    # To get stable or beta toolchain, do ..darwin.stable.defaultToolchain, e.g., or to get the complete toolchain (including stuff like MIRI that I probably don't need) replace default.toolchain with complete.toolchain or latest.toolchain.
    # Can also get toolchains for specified targets, e.g. targets.wasm32-unknown-unknown.latest.toolchain
    fenix.packages."${pkgs.system}".latest.toolchain
    # rust
    cargo-audit
    cargo-flamegraph
    cargo-generate
    cargo-diet
    cargo-msrv
    cargo-semver-checks
    (lib.mkIf stdenv.isDarwin cargo-instruments)
  ];
}
