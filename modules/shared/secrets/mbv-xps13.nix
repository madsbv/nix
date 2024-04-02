{ user, flake-root, ... }:

{
  imports = [ ./server.nix ];
  age.secrets = {
    ssh-user-mbv-xps13 = {
      rekeyFile = flake-root + "/secrets/ssh/id_ed25519-mbv-xps13.age";
      owner = user;
    };
    home-wifi-nm = {
      rekeyFile = flake-root + "/secrets/other/home-wifi.nmconnection.age";
    };
  };
}
