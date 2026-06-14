{
  config,
  lib,
  flake-root,
  ...
}:
let
  cfg = config.local.awesomewm;
in
{
  options.local.awesomewm.enable = lib.mkEnableOption "AwesomeWM user config";
  config = lib.mkIf cfg.enable {
    xdg.configFile = {
      "awesome" = {
        source = flake-root + "/config/awesome";
        recursive = true;
      };
    };
  };
}
