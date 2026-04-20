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
  services = lib.mkIf cfg.enable {
    tailscale = {
      enable = true;
      authKeyFile = lib.mkIf cfg.useAuthkey cfg.authkeyPath;
      extraUpFlags = [ "--ssh" ];
    };
  };

}
