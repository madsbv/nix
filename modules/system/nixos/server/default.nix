{
  config,
  lib,
  mod,
  ...
}:

let
  # A user to use as manual SSH target. Can use sudo.
  cfg = config.local.server;
in
{
  imports = [
    (mod "system/nixos/common")
    (mod "system/common/server")
    ./secrets.nix
  ];

  options.local.server = {
    user = lib.mkOption { default = "mvilladsen"; };
    timezone = lib.mkOption { default = "America/Detroit"; };
  };

  config = {
    local = {
      nixos.common = {
        inherit (cfg) timezone user;
      };
      keys = {
        enable = true;
        enable_authorized_access = true;
        authorized_users = [ cfg.user ];
      };
    };

    services = {
      tailscale = {
        enable = true;
        authKeyFile = config.age.secrets.tailscale-server-authkey.path;
        extraUpFlags = [ "--ssh" ];
      };
    };

    environment.persistence."/nix/persist" = {
      directories = [
        "/var/log"
        "/var/lib"
      ];
    };
  };
}
