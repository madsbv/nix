_:

{
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    # TODO: We might want to persist some tailscale state
    directories = [
      "/etc/nixos"
      "/etc/ssh"
      "/etc/NetworkManager/system-connections"
      "/var/log"
      "/var/lib"
    ];
    files = [ "/etc/machine-id" ];
  };
}
