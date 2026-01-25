{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.go;
in
{
  options.local.dev.go.enable = lib.mkEnableOption "Go";

  config = lib.mkIf cfg.enable {
    programs.go = {
      enable = true;
      env = {
        CGO_ENABLED = "0";
      };
      telemetry.mode = "off";
    };
    home = {
      packages = with pkgs; [
        go
        gopls
        gomodifytags
        gotests
        gore
        gotools
      ];
    };
  };
}
