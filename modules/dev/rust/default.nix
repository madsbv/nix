{
  lib,
  config,
  pkgs,
  inputs,
  ...
}:

{
  home-manager.sharedModules = lib.mkIf config.local.hm.enable [
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
            c = "job:clippy"; # Already runs clippy with --all-targets
            d = "job:doc-open";
            t = "job:test";
            r = "job:run";
            # Custom job commands
            f = "job:clippy-fix";
            v = "job:semver-checks";
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
      home.sessionPath = [ "$HOME/.cargo/bin" ];
    }
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
    # (lib.mkIf stdenv.isDarwin cargo-instruments)
  ];
}
