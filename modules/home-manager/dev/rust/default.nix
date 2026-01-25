{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

let
  cfg = config.local.dev.rust;
in
{
  options.local.dev.rust.enable = lib.mkEnableOption "Rust";

  config = lib.mkIf cfg.enable {

    programs.bacon = {
      enable = true;
      settings = {
        keybindings = {
          # Some defaults
          s = "toggle-summary";
          w = "toggle-wrap";
          b = "toggle-backtrace";
          # Vim modifications of defaults
          esc = "back";
          g = "scroll-to-top";
          shift-g = "scroll-to-bottom";
          k = "scroll-lines(-1)";
          j = "scroll-lines(1)";
          ctrl-u = "scroll-page(-1)";
          ctrl-d = "scroll-page(1)";
          # Default job commands
          a = "job:check-all";
          i = "job:initial";
          c = "job:clippy-all"; # Already runs clippy with --all-targets
          d = "job:doc-open";
          t = "job:test";
          r = "job:run";
          # Custom keybindings
          f = "job:clippy-fix";
          v = "job:semver-checks";
          l = "job:run-long"; # For long-running programs, e.g. servers
        };
        jobs = {
          semver-checks = {
            command = [
              "cargo"
              "semver-checks"
            ];
            need_stdout = true;
          };
          clippy-fix = {
            command = [
              "cargo"
              "clippy"
              "--fix"
              "--allow-staged"
              "--color"
              "always"
            ];
            need_stdout = false;
          };
        };
      };
    };

    # Enables using programs installed via Cargo
    home =
      let
        # Relative to home
        cargoHomeName = ".cargo";
        cargoHome = "${config.home.homeDirectory}/${cargoHomeName}";
      in
      {
        sessionPath = [ "${cargoHome}/bin" ];
        # To fix cargo failing to find libiconv on C linking
        sessionVariables = {
          CARGO_HOME = cargoHome;
          CARGO_TARGET_DIR = "${cargoHome}/target";
          LIBRARY_PATH = lib.mkIf pkgs.stdenv.isDarwin [ "${pkgs.darwin.libiconv}/lib" ];
        };
        file.cargo-toml = {
          target = "${cargoHomeName}/config.toml";
          text = ''
            [alias]     # command aliases
            b = "build"
            c = "check"
            t = "test"
            r = "run"
            rr = "run --release"

            [build]
            target-dir = "${cargoHome}/target"         # path of where to place all generated artifacts
            incremental = true            # whether or not to enable incremental compilation

            [future-incompat-report]
            frequency = 'always' # when to display a notification about a future incompat report

            [net]
            git-fetch-with-cli = true
          '';
        };

        packages = with pkgs; [
          # NOTE: Provides rustc, cargo, rustfmt, clippy, from the nightly toolchain.
          # To get stable or beta toolchain, do ..darwin.stable.defaultToolchain, e.g., or to get the complete toolchain (including stuff like MIRI that I probably don't need) replace default.toolchain with complete.toolchain or latest.toolchain.
          # Can also get toolchains for specified targets, e.g. targets.wasm32-unknown-unknown.latest.toolchain
          inputs.fenix.packages."${pkgs.stdenv.hostPlatform.system}".latest.toolchain
          # XXX: Define a justfile type situation for running common checks as one job? Could be more bacon jobs, but some of these are not really suitable for that
          cargo-audit
          cargo-flamegraph
          cargo-generate
          cargo-diet
          cargo-msrv
          # 251122: Version 0.45 failing to build on Darwin
          (lib.mkIf pkgs.stdenv.isLinux cargo-semver-checks)
          cargo-watch
          # cargo-instruments is defined in an overlay, and needs updating to be used
          # (lib.mkIf stdenv.isDarwin cargo-instruments)
        ];
      };

    # This overlay needs to be applied at the system level since it affects how packages are built
    # In a pure home-manager setup, this would need to be configured differently
    nixpkgs.overlays = [ inputs.fenix.overlays.default ];
  };
}
