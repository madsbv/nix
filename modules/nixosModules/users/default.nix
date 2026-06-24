{
  config,
  lib,
  pkgs,
  ...
}:
# NixOS extension of the systemModule of the same name
let
  cfg = config.local.users;
in
{
  users.users = lib.mkIf cfg.enable (
    lib.mapAttrs' (
      _: u:
      lib.nameValuePair "${u.username}" {
        isNormalUser = true;
        extraGroups = u.extraGroups;
      }
    ) cfg.users
  );
}
