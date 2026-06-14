{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.tailscale;

in
{
  options.local.tailscale = {
    enable = lib.mkOption { default = true; };
    useAuthkey = lib.mkOption { default = false; };
    authkeyPath = lib.mkOption;
  };
  config = lib.mkIf cfg.enable {
    services = {
      tailscale = {
        enable = true;
        authKeyFile = lib.mkIf cfg.useAuthkey cfg.authkeyPath;
        extraUpFlags = [ "--ssh" ];
      };
    };

  };
}
