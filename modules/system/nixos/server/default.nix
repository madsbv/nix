{
  config,
  lib,
  ...
}:

let
  # A user to use as manual SSH target. Can use sudo.
  cfg = config.local.server;
in
{
  imports = [
    ./secrets.nix
  ]
  ++ (with modules; [
    nixos.common
    system.common.server
  ]);

  options.local.server = {
    user = lib.mkOption { default = "mvilladsen"; };
    timezone = lib.mkOption { default = "Europe/Copenhagen"; };
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
