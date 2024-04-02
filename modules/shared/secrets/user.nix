{ user, flake-root, config, ... }:

{
  age.secrets = {
    "ssh-user-${user}" = {
      rekeyFile = flake-root
        + "/secrets/ssh/id_ed25519.${config.networking.hostName}.age";
      owner = user;
    };
  };
}
