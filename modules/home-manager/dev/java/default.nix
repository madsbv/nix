{
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.java;
in
{
  options.local.dev.java.enable = lib.mkEnableOption "Java";

  config = lib.mkIf cfg.enable {
    programs.java.enable = true;
  };
}
