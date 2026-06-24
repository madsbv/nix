{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:
let
  cfg = config.local.common;
in
{
  options.local.common = {
    # A collection of general user/system information that might be accessed in multiple modules
    user = lib.mkOption { default = "mvilladsen"; };
    timezone = lib.mkOption { default = "Europe/Copenhagen"; };
    hostname = lib.mkOption { default = hostname; };
  };
}
