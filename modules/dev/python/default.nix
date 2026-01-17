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
    ty
  ];

  home-manager.sharedModules = lib.mkIf config.local.hm.enable [
    (_: {
      programs = {
        uv = {
          enable = true;
          settings = {
            python-downloads = "never";
            python-preference = "only-system";
          };
        };
        ty.enable = true;
        ruff = {
          enable = true;
        };
      };
    })
  ];
}
