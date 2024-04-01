{ flake-root, ... }:

{
  age.secrets = {
    ssh-user-mbv-mba = {
      rekeyFile = flake-root + "/secrets/ssh/id_ed25519-mbv-mba.age";
      owner = "mvilladsen";
    };
  };
}
