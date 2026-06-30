{
  config,
  flake-root,
  ...
}:

{
  imports = [
    ./secrets.nix
  ];
  age.secrets = {
    tailscale-server-authkey = {
      rekeyFile = flake-root + "/secrets/tailscale/24-04-02-server-authkey.age";
    };
  };
  local = {
    keys = {
      enable = true;
      enable_authorized_access = true;
      authorized_users = [ cfg.user ];
    };
    tailscale = {
      enable = true;
      useAuthkey = true;
      authkeyPath = config.age.secrets.tailscale-server-authkey.path;
    };
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/log"
      "/var/lib"
    ];
  };
}
