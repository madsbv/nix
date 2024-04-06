{ flake-root, ... }:

{
  age.secrets = {
    mbsyncrc = {
      rekeyFile = flake-root + "/secrets/other/mbsyncrc.age";
      owner = "mvilladsen";
    };
    mu-init-addresses = {
      rekeyFile = flake-root + "/secrets/other/mu-init-addresses.age";
      owner = "mvilladsen";
    };
  };
}
