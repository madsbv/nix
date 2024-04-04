# It is recommended to
user:
{ hostname, flake-root, ... }:

{
  age.secrets = {
    "id.${hostname}.${user}" = {
      rekeyFile = flake-root
        + "/secrets/ssh/id_ed25519.${hostname}.${user}.age";
      owner = user;
    };
  };
}
