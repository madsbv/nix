_:

{
  disko.devices = {
    disk = {
      sda = {
        type = "disk";
        device = "/dev/sda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            swap = {
              size = "20G";
              content = {
                type = "swap";
                resumeDevice = true;
              };
            };
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "znix";
              };
            };
          };
        };
      };
    };
    zpool.znix = {
      type = "zpool";
      mode = ""; # Single disk so this doesn't really matter
      rootFsOptions = {
        compression = "zstd";
        "com.sun:auto-snapshot" = "false"; # Managed through nixos
        acltype = "posixacl";
        canmount = "off";
        dnodesize = "auto";
        normalization = "formD";
        relatime = "on";
        xattr = "sa";
        mountpoint = "none";
      };
      options = {
        ashift = "12";
        autotrim = "on";
      };

      datasets = {
        nix = {
          type = "zfs_fs";
          mountpoint = "/nix";
        };
        nix-persist = {
          type = "zfs_fs";
          mountpoint = "/nix/persist";
        };
        nix-persist-home = {
          type = "zfs_fs";
          mountpoint = "/nix/persist/home";
        };
      };
    };
    nodev."/" = {
      fsType = "tmpfs";
      mountOptions = [
        # Restic operations like to use a bunch of temp files. Besides, we have plenty of swap space to work with.
        "size=20G"
        "defaults"
        "mode=755"
      ];
    };
  };
}
