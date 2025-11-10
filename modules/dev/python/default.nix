{
  pkgs,
  lib,
  config,
  ...
}:

{
  environment.systemPackages = with pkgs; [
    python3
    isort
    black
    python311Packages.pyflakes
    python311Packages.pytest
    basedpyright
    uv
    ruff
  ];

  home-manager.sharedModules = lib.mkIf config.local.hm.enable [
    (
      { ... }:
      {
        programs.uv = {
          enable = true;
          settings = {
            python-downloads = "never";
            python-preference = "only-system";
          };
        };
      }
    )
  ];
}
