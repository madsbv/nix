{ flake-root, ... }:

{
  age.secrets = {
    id_ed25519-mbv-mba = {
      rekeyFile = flake-root + "/secrets/id_ed25519-mbv-mba.age";
      owner = "mvilladsen";
    };
    tailscale-ephemeral-vms-authkey.rekeyFile = flake-root
      + "/secrets/tailscale/24-03-30-ephemeral-vms.authkey.age";
  };
}
