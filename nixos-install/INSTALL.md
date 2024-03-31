# Nix

On non-NixOS systems, use [The Determinate Nix Installer](https://github.com/DeterminateSystems/nix-installer) to install Nix.

# NixOS
Impermanence: The [Making the System Amnesiac](https://xeiaso.net/blog/paranoid-nixos-2021-07-18/) section of this page has both links to the most important resources, and an excellent guide, for impermanent root on NixOS. The guide is for tmpfs, but links to a zfs based setup guide as well.

For NixOS on ZFS root, see the install guide: https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS.html
This can be mixed with impermanence, either by putting the persistent file systems in ZFS data sets and root on tmpfs, or by putting even root on ZFS but reverting to a blank snapshot at every boot.

## TODO
Currently this approach does not involve any disk encryption. I might want to do that, but I have to figure out how to boot and enter decryption keys remotely.

Use nixos-generators to create an install image that includes my ssh key so I can ssh in without any manual input on the target machine.
Alternatively we can use pixiecore for network booting directly: https://nixos.wiki/wiki/Netboot

We can even use tailscale with [auth keys](https://tailscale.com/kb/1085/auth-keys) to automate getting an ip address to ssh over. Use a reusable tailscale authkey managed by age and have it be built into the install image at build-time.

NOTE: The combination of netboot and tailscale with this level of automation has security implications, namely that anyone on the network can acquire the boot image and hence tailscale authkeys.

Then use NixOS-anywhere for the actual install, and `nixos-rebuild switch` with the `--target-host root@<ip>` option to deploy flake output remotely.


Another thought: NixOS has system.autoUpgrade.flake which allows for pointing to a github repo for the flake to build, for example. We could in principle make our configs public and transition from install image this way, or even just pull the final config directly from github for the initial install, without any hard coding in the install image. Debugging would be harder though.
We could then even build CI in with Github actions, and run autoUpgrade in the final config as well with flake input updates run in Github CI too.

### Plan of attack

Goals: Set up macos linux builder, installer images with ephemeral tailscale auth key and ssh access, and nixos-anywhere/morph/something remote deployment tool. Then use to set up laptop and desktop.

1. ~~Get VM install script fully working, without any of the fancy tools above. Don't worry about automatically transferring configuration files or scripts, that will be solved by nixos-generators later.~~
     Step 1 results, workflow: 
     - As root in local terminal on vm: `mkdir -p /root/.ssh && curl https://github.com/madsbv.keys > /root/.ssh/authorized_keys`
     - Script transfer-config.sh which uses scp to transfer nix config and setup script to /root/nixos on vm
     - script install-nixos.sh which, when run on vm, automatically configures disks and installs nixos, then shuts down vm.
     - Remove install iso from vm and boot to installed os
2. ~~Convert to nixos-generators flake and get a working install iso/vm image that does everything from the script in step 1 hands off.~~
     - Find a way to include the final config in the iso without hard-coding, e.g. by pointing to a config folder in install-script.nix.
     - Probable solution: Follow the example of https://github.com/JustinLex/jlh-h5b/blob/main/nodes/flake.nix and define system config and nixos-generator config in the same flake, then in the install script, refer to self.outPath... in the nixos-install command. Can I also cp the result to /etc/nixos?
3. Integrate tailscale and tailscale SSH in the above on VMs, including deploying with authkeys somehow (look into agenix-rekey).
4. Get a working image on the xps.
5. If supported, get PXE boot on xps working with pixiecore.

So far, the steps above should get us to a state where nixos is installed on the machine hands-free, and we have ssh access over Tailscale. There's some missing pieces:
- This only works if we already have the disk layout and hardware-configuration.nix
- The configuration has to be hardcoded in the install iso; the iso will go out of date quickly, so we'd have to go in and update the config anyway.

We can use nixos-anywhere to fix this. The workflow will be as follows:
- Use custom installer image to boot to install environment with tailscale running
- If this is a new machine, ssh in manually and explore the disk layout as well as generating hardware-configuration.nix without file systems (`nixos-generate-config --no-filesystems`). There should be a script on the install iso to easily generate the hardware-configuration.nix, and ideally write necessary disk info to a file.
-   Customize nixos configuration to this new machine
- Deploy desired config via nixos-anywhere.

Ideally we can integrate nixos-anywhere and nixos-generator sufficiently that we can build install images with nixos-generator from any nixos-anywhere config. Then we could have one fixed new-install image for use with nixos-anywhere for initial setup, and then, if desired, build new install images for repeat deployment of the same or similar machines.

This gives us further steps:
6. Remove the automatic install script from the nixos-generator config from steps 1-5, and instead make the install iso boot to an install environment that has my ssh key/tailscale auth already loaded, together with whatever tools are necessary for any manual spelunking I might do (git could be useful).
7. Take the installed config from steps 1-5, and test that we can install that final config using the nixos-anywhere workflow.
8. Test the workflow for a new setup.

We're now at the point where installation should be about as hands-free as is reasonable. A possible next step would be to look into nix deployment tools like nixops or morph for managing everything together.

## Steps for tmpfs root, persistent data on ZFS

Boot into installer in whatever way and get networking going.

### SSH in from laptop

- `curl https://github.com/madsbv.keys > /root/.ssh/authorized_keys`: Add ssh key to authorized keys on root so we can ssh in.
- Get IP with `ifconfig` and ssh in from laptop to do rest of setup.

### Partition disk with ZFS and set up file system

Follows https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/Root%20on%20ZFS.html for ZFS setup, but with disk layout from https://xeiaso.net/blog/paranoid-nixos-2021-07-18/

- Set `DISK` variable to the path of the install disk--e.g. in a VM this might be `DISK='/dev/vda'`.
- set `SWAPSIZE` and `RESERVE` in GiB; `RESERVE` is the space left at the end of the disk, minimum 1GiB.
- Partition as follows:
```
parted --script --align=optimal "${DISK}" -- \
mklabel gpt \
mkpart EFI 1MiB 4GiB \
mkpart persistpool 4GiB -$((SWAPSIZE + RESERVE))GiB \
mkpart swap -$((SWAPSIZE + RESERVE))GiB -"${RESERVE}"GiB \
set 1 esp on \

partprobe "${DISK}"
```
The last command tells the kernel of the updated partition table.

If the disk is not already clear of all partition tables and data structures, if it is flash based it can be cleared with `blkdiscard -f "${DISK}"`.
- Name the new partitions:
```
PEFI=/dev/disk/by-partlabel/EFI
PPOOL=/dev/disk/by-partlabel/persistpool
PSWAP=/dev/disk/by-partlabel/swap
```
- `mkswap ${PSWAP}`
- `swapon ${PSWAP}`: Set up swap before starting nixos config so the swap automatically gets added to hardware-configuration.nix
- `MNT=$(mktemp -d)`: Create a mountpoint
- Create data pool:
```
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
```
- `mount -t tmpfs none ${MNT}`: Create and mount root tmpfs
- `mkdir -p ${MNT}/{boot,nix,etc/{nixos,ssh},var/{lib,log}}`: Set up folders that we will mount persistent file systems to.
- Create zfs datasets. The goal of this layout is to separate the nix store, persistent system files, and persistent user files from each other.
```
zfs create -o canmount=noauto -o mountpoint=legacy persistpool/nix
zfs create -o canmount=noauto -o mountpoint=legacy persistpool/nix/persist
zfs create -o canmount=noauto -o mountpoint=legacy persistpool/nix/persist/home
```
- `mkfs.vfat -n EFI "${PEFI}"`: Format ESP
- Mount file systems:
```
mount -t zfs persistpool/nix "${MNT}"/nix
mount -m -t zfs persistpool/nix/persist "${MNT}"/nix/persist
mount -m -t zfs persistpool/nix/persist/home "${MNT}"/nix/persist/home
mount -t vfat -o fmask=0077,dmask=0077,iocharset=iso8859-1 "${PEFI}" "${MNT}"/boot
```
NOTE: In the OpenZFS install guide they use the `-o X-mount.mkdir` flag (equivalently `-m`) on mount. This creates the target mount directory if it doesn't already exist. We don't want that on root file systems, because if the folder doesn't exist, we have likely not set up the tmpfs correctly, so we want an error in that case. However, we do want it when mounting the child ZFS datasets so we can avoid having to create those mountpoints manually.
- `mkdir -p ${MNT}/nix/persist/{etc/{nixos,ssh},var/{lib,log}}`: Create matching directories on the persistent file system
- Bind mount things together (this will be handled by the impermanence module later)
```
mount -o bind ${MNT}/nix/persist/etc/nixos ${MNT}/etc/nixos
mount -o bind ${MNT}/nix/persist/var/log ${MNT}/var/log
```



### Generate nixos configuration and set file system options

- `nixos-generate-config --root ${MNT}`
- Edit configuration.nix, add the following mount point options:
```
  fileSystems."/".options = [ "defaults" "size=2G" "mode=755" ];
  fileSystems."/nix".neededForBoot = true;
  fileSystems."/nix/persist".neededForBoot = true;
  fileSystems."/nix/persist/home".neededForBoot = true;
  fileSystems."/boot".options = [ "umask=0077" ];
```
The mode on / is needed for things like OpenSSH to accept the file system as secure and work correctly. The umask on /boot is to hide the random seed from world: https://github.com/NixOS/nixpkgs/issues/279362. The neededForBoot flags on the persistent partitions is for the Impermanence module.
- Set the boot mount
- Set networking.hostId to the output of `head -c 8 /etc/machine-id` (needed for ZFS to behave well)

Note: Some guides will tell you to set this in hardware-configuration.nix, but that should not be user-modified, as it's expected that nixos-generate-config can be rerun, and that will overwrite hardware-configuration.nix.

### Set up flakes and edit system configuration

Based in part on https://willbush.dev/blog/impermanent-nixos/#configure-with-flakes

- Get some useful tools for finalizing the installation:
`export NIX_CONFIG="experimental-features = nix-command flakes`
`nix shell nixpkgs#git nixpkgs#tree nixpkgs#gdu`
- Initialize etc/nixos as a git repo and add the configuration files
- Set up a flake.nix (either using existing, setting up from scratch, or basing it on: https://github.com/willbush/ex-nixos-starter-config/blob/main/flake.nix)

Make sure to: 
- Enable a bootloader
- Set hostId and hostName
- Set timezone, locale, keymap
- Enable OpenSSH service
- Set users.users.root.initialhashedpassword (use `mkpasswd -m SHA-512` to generate the hash)
- Set users.users.root.openssh.authorizedKeys.keys to your ssh public key to allow ssh access after reboot
- Set up the Impermanence module and persist necessary files, including at least: /etc/nixos, /etc/machine-id, `/etc/ssh/ssh_host_*`
- Remember to stage all nix configuration files in the git repo or nix won't be happy.

### Install NixOS and reboot

`export NIX_CONFIG="experimental-features = nix-command flakes"`
`nix flake check` <- to catch and correct any errors more quickly
`nixos-install --flake .#%HOSTNAME% --root ${MNT} --no-root-passwd`
`shutdown -h now`

Eject NixOS install ISO and start VM again.
