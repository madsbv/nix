{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.python;
in
{
  options.local.dev.python.enable = lib.mkEnableOption "Python";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      python3
      isort
      black
      python311Packages.pyflakes
      python311Packages.pytest
      basedpyright
      uv
      ruff
      ty
    ];

    programs = {
      uv = {
        enable = true;
        settings = {
          python-downloads = "never";
          python-preference = "only-system";
        };
      };
    };
  };
}
