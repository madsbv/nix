#!/usr/bin/env -S NIX_CONFIG="experimental-features = nix-command flakes" nix shell nixpkgs#bash nixpkgs#git --command bash
# Nix as shebang interpreter seems to be only supported from 2.19 onward, this is a workaround based on: https://github.com/NixOS/nixpkgs/issues/280033
set -euxo pipefail

# Set up ssh
# mkdir -p /root/.ssh
# curl https://github.com/madsbv.keys > /root/.ssh/authorized_keys

# echo "SSH available"
# The commands above will be run manually.

DISK=/dev/vda

blkdiscard -f "${DISK}"

export SWAPSIZE=4
export RESERVE=4

parted --script --align=optimal "${DISK}" -- \
mklabel gpt \
mkpart EFI 1MiB 4GiB \
mkpart persistpool 4GiB -$((SWAPSIZE + RESERVE))GiB \
mkpart swap -$((SWAPSIZE + RESERVE))GiB -"${RESERVE}"GiB \
set 1 esp on \

partprobe "${DISK}"

export PEFI=/dev/disk/by-partlabel/EFI
export PPOOL=/dev/disk/by-partlabel/persistpool
export PSWAP=/dev/disk/by-partlabel/swap

# Wait for partition changes to come through
# Not sure if actually needed or based on false alarm
sleep .5

mkswap -L swap "${PSWAP}"
swapon -L swap

MNT="$(mktemp -d)"
export MNT

zpool create \
    -o ashift=12 \
    -o autotrim=on \
    -R "${MNT}" \
    -O acltype=posixacl \
    -O canmount=off \
    -O dnodesize=auto \
    -O normalization=formD \
    -O relatime=on \
    -O xattr=sa \
    -O mountpoint=none \
    persistpool \
    ${PPOOL}

mount -t tmpfs none "${MNT}"
mkdir -p "${MNT}"/{boot,nix,etc/{nixos,ssh},var/{lib,log}}

zfs create -o canmount=noauto -o mountpoint=legacy persistpool/nix
zfs create -o canmount=noauto -o mountpoint=legacy persistpool/nix/persist
zfs create -o canmount=noauto -o mountpoint=legacy persistpool/nix/persist/home
mkfs.vfat -n EFI "${PEFI}"

mount -t zfs persistpool/nix "${MNT}"/nix
mount -m -t zfs persistpool/nix/persist "${MNT}"/nix/persist
mount -m -t zfs persistpool/nix/persist/home "${MNT}"/nix/persist/home
mount -t vfat -o fmask=0077,dmask=0077,iocharset=iso8859-1 "${PEFI}" "${MNT}"/boot

mkdir -p "${MNT}"/nix/persist/{etc/{nixos,ssh},var/{lib,log}}

mount -o bind "${MNT}"/nix/persist/etc/nixos "${MNT}"/etc/nixos
mount -o bind "${MNT}"/nix/persist/var/log "${MNT}"/var/log

echo "Disk setup done"

cp -r . "${MNT}"/etc/nixos
cd "${MNT}"/etc/nixos

export NIX_CONFIG="experimental-features = nix-command flakes"
git init
git add .
nixos-install --flake .#nixos-guest --root "${MNT}" --no-root-passwd

echo "Installed NixOS"
echo "Powering down now"
echo "Remember to remove install ISO!"

shutdown -h now
