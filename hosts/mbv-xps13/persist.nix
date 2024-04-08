_:

{
  environment.persistence."/nix/persist" = {
    hideMounts = true;
    directories = [
      "/etc/nixos"
      "/etc/NetworkManager/system-connections"
      "/etc/ssh" # We need the entire directory so we can set neededForBoot
      "/var/log"
      "/var/lib"
      # Restic basically needs its cache to be able to run in a reasonable amount of time
      "/var/cache/restic-backups-persist"
    ];
    files = [ "/etc/machine-id" ];
  };
  fileSystems = {
    # I don't know how many of these we actually need
    # "/".neededForBoot = true;
    # "/nix".neededForBoot = true;
    "/nix/persist".neededForBoot = true;
    # "/nix/persist/home".neededForBoot = true;
    "/etc/ssh".neededForBoot = true;
  };
}
