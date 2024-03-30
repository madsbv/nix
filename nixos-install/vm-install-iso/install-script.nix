{ path, config, pkgs, ... }:
# Script approach based on https://github.com/Xe/nixos-configs/blob/master/media/autoinstall-paranoid/iso.nix
#
# To build on Darwin we need a linux build vm, see https://nixos.org/manual/nixpkgs/unstable/#sec-darwin-builder
{
  systemd.services.install = {
    description = "Bootstrap a NixOS installation";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" "polkit.service" ];
    path = [ "/run/current-system/sw/" ];
    script = ''
      set -eux

      DISK=/dev/vda

      blkdiscard -f "$DISK"

      export SWAPSIZE=4
      export RESERVE=4

      parted --script --align=optimal "$DISK" -- \
      mklabel gpt \
      mkpart EFI 1MiB 4GiB \
      mkpart persistpool 4GiB -$((SWAPSIZE + RESERVE))GiB \
      mkpart swap -$((SWAPSIZE + RESERVE))GiB -"$RESERVE"GiB \
      set 1 esp on \

      partprobe "$DISK"

      export PEFI=/dev/disk/by-partlabel/EFI
      export PPOOL=/dev/disk/by-partlabel/persistpool
      export PSWAP=/dev/disk/by-partlabel/swap

      # Wait for partition changes to come through
      # Not sure if actually needed or based on false alarm
      sleep .5

      mkswap -L swap "$PSWAP"
      swapon -L swap

      MNT="$(mktemp -d)"
      export MNT

      zpool create \
          -o ashift=12 \
          -o autotrim=on \
          -R "$MNT" \
          -O acltype=posixacl \
          -O canmount=off \
          -O dnodesize=auto \
          -O normalization=formD \
          -O relatime=on \
          -O xattr=sa \
          -O mountpoint=none \
          persistpool \
          $PPOOL

      mount -t tmpfs none "$MNT"
      mkdir -p "$MNT"/{boot,nix,etc/{nixos,ssh},var/{lib,log}}

      zfs create -o canmount=noauto -o mountpoint=legacy persistpool/nix
      zfs create -o canmount=noauto -o mountpoint=legacy persistpool/nix/persist
      zfs create -o canmount=noauto -o mountpoint=legacy persistpool/nix/persist/home
      mkfs.vfat -n EFI "$PEFI"

      mount -t zfs persistpool/nix "$MNT"/nix
      mount -m -t zfs persistpool/nix/persist "$MNT"/nix/persist
      mount -m -t zfs persistpool/nix/persist/home "$MNT"/nix/persist/home
      mount -t vfat -o fmask=0077,dmask=0077,iocharset=iso8859-1 "$PEFI" "$MNT"/boot

      mkdir -p "$MNT"/nix/persist/{etc/{nixos,ssh},var/{lib,log}}

      mount -o bind "$MNT"/nix/persist/etc/nixos "$MNT"/etc/nixos
      mount -o bind "$MNT"/nix/persist/var/log "$MNT"/var/log

      echo "Disk setup done"

      ${pkgs.rsync}/bin/rsync -r "${path}/" "$MNT"/etc/nixos

      export NIX_CONFIG="experimental-features = nix-command flakes"
      # It's possible that we need to prefix the flake path with "path:" as in https://github.com/JustinLex/jlh-h5b/blob/main/nodes/common.nix, but test without first.
        ${config.system.build.nixos-install}/bin/nixos-install --flake "${path}"#nixos-guest --root "$MNT" --no-root-passwd


      echo "Installed NixOS"
      echo "Powering down"
      echo "Remember to remove install ISO!"

      ${pkgs.systemd}/bin/shutdown now
    '';
    environment = config.nix.envVars // {
      inherit (config.environment.sessionVariables) NIX_PATH;
      HOME = "/root";
    };
    serviceConfig = { Type = "oneshot"; };
  };
  system.stateVersion = "23.11";
}
