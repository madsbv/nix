{
  hostname,
  flake-root,
  lib,
  config,
  ...
}:

{
  options.local.ssh-clients.users = lib.mkOption {
    description = "List of users for which to deploy age-encrypted private SSH keys.";
    default = [ ];
  };

  config.age.secrets = lib.mkMerge (
    map (user: {
      "id.${hostname}.${user}" = {
        rekeyFile = flake-root + "/secrets/ssh/id_ed25519.${hostname}.${user}.age";
        owner = user;
      };
    }) config.local.ssh-clients.users
  );
}
