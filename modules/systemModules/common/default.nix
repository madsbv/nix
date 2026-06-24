{
  lib,
  hostname,
  ...
}:
{
  options.local.common = {
    timezone = lib.mkOption { default = "Europe/Copenhagen"; };
    hostname = lib.mkOption { default = hostname; };
  };
}
