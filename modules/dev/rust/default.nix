{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

{
  home-manager.sharedModules = lib.mkIf config.local.hm.enable [
    (
      { config, ... }:
      let
        # Relative to home
        cargo-home = ".cargo";
      in
      {
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
        home = {
          sessionPath = [ "$HOME/.cargo/bin" ];
          sessionVariables = {
            CARGO_HOME = "${config.home.homeDirectory}/${cargo-home}";
          };
          file.cargo-toml = {
            target = "${cargo-home}/config.toml";
            text = ''
              [alias]     # command aliases
              b = "build"
              c = "check"
              t = "test"
              r = "run"
              rr = "run --release"

              [build]
              target-dir = "$CARGO_HOME/target"         # path of where to place all generated artifacts
              incremental = true            # whether or not to enable incremental compilation

              [future-incompat-report]
              frequency = 'always' # when to display a notification about a future incompat report

              [net]
              git-fetch-with-cli = true
            '';
          };
        };
      }
    )
  ];

  nixpkgs.overlays = [ inputs.fenix.overlays.default ];
  environment.systemPackages = with pkgs; [
    # NOTE: Provides rustc, cargo, rustfmt, clippy, from the nightly toolchain.
    # To get stable or beta toolchain, do ..darwin.stable.defaultToolchain, e.g., or to get the complete toolchain (including stuff like MIRI that I probably don't need) replace default.toolchain with complete.toolchain or latest.toolchain.
    # Can also get toolchains for specified targets, e.g. targets.wasm32-unknown-unknown.latest.toolchain
    inputs.fenix.packages."${pkgs.system}".latest.toolchain
    # XXX: Define a justfile type situation for running common checks as one job? Could be more bacon jobs, but some of these are not really suitable for that
    cargo-audit
    cargo-flamegraph
    cargo-generate
    cargo-diet
    cargo-msrv
    cargo-semver-checks
    cargo-watch
    # (lib.mkIf stdenv.isDarwin cargo-instruments)
  ];
}
