{ flake-root, ... }:

{
  imports = [ ./server.nix ];
  age.secrets = {
    ssh-root-mbv-xps13 = {
      rekeyFile = flake-root + "/secrets/ssh/id_ed25519-mbv-xps13.age";
      owner = "root";
    };
  };
}
