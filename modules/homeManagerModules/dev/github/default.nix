{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.github;
in
{
  options.local.dev.github.enable = lib.mkEnableOption "Development tools";

  config = lib.mkIf cfg.enable {
    programs = {
      gh = {
        enable = true;
        settings.editor = "vim";
      };
    };
  };
}
