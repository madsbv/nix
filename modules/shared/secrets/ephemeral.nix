{ flake-root, ... }:

{
  age.secrets = {
    ssh-host-ephemeral.rekeyFile = flake-root
      + "/secrets/ssh/id_ed25519-ephemeral.age";
    tailscale-ephemeral-vms-authkey = {
      rekeyFile = flake-root
        + "/secrets/tailscale/24-03-30-ephemeral-vms-authkey.age";
      name = "tailscale-authkey";
    };
  };
}
