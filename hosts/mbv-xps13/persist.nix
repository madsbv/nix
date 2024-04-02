_:

{
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    # TODO: We might want to persist some tailscale state
    directories = [ "/etc/nixos" "/var/log" "/var/lib" ];
    files = [
      "/etc/machine-id"
      "/etc/ssh/ssh_host_rsa_key"
      "/etc/ssh/ssh_host_rsa_key.pub"
      "/etc/ssh/ssh_host_ed25519_key"
      "/etc/ssh/ssh_host_ed25519_key.pub"
    ];
  };
}
