{ flake-root, ... }:

{
  age.secrets = {
    tailscale-server-authkey = {
      rekeyFile = flake-root + "/secrets/tailscale/24-04-02-server-authkey.age";
    };
  };
}
