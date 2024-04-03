_:

{
  fileSystems = {
    "/".neededForBoot = true;
    "/nix".neededForBoot = true;
    "/nix/persist".neededForBoot = true;
    "/nix/persist/home".neededForBoot = true;
  };
  disko.devices = {
    disk = {
      nvme0n1 = {
        type = "disk";
        device = "/dev/nvme0n1";
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
            # We probably don't need swap at all, but it's easier to set up too much now, and we have plenty of disk space.
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
      mountOptions = [ "size=4G" "defaults" "mode=755" ];
    };
  };
}
