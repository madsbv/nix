{ config, flake-root, ... }:

let
  owner = if config.local.users.enable then config.local.users.primaryUser else "mvilladsen";
in
{
  age.secrets = {
    mbsyncrc = {
      inherit owner;
      rekeyFile = flake-root + "/secrets/other/mbsyncrc.age";
    };
    mu-init-addresses = {
      inherit owner;
      rekeyFile = flake-root + "/secrets/other/mu-init-addresses.age";
    };
    pmbridge-password = {
      inherit owner;
      rekeyFile = flake-root + "/secrets/other/pmbridge-password.age";
    };
  };
}
