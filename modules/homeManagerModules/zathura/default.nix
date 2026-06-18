{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.zathura;
in {
  options.local.zathura = {
    enable = lib.mkEnableOption "Zathura PDF viewer";
  };

  config = lib.mkIf cfg.enable {
    programs.zathura.enable = true;
  };
}
