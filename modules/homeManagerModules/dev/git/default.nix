{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.git;
in
{
  options.local.dev.git.enable = lib.mkEnableOption "Development tools";

  config = lib.mkIf cfg.enable {
    programs = {
      git = {
        enable = true;
        lfs = {
          enable = true;
        };
      };
    };
  };
}
