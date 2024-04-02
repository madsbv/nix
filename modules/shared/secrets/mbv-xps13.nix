{ flake-root, ... }:

{
  imports = [ ./server.nix ./user.nix ];
  age.secrets = {
    home-wifi-nm = {
      rekeyFile = flake-root + "/secrets/other/home-wifi.nmconnection.age";
    };
  };
}
