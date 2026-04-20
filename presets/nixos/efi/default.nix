{
  lib,
  config,
  ...
}:

{
  boot = {
    # Use systemd during boot as well except:
    # - systems with raids as this currently require manual configuration: https://github.com/NixOS/nixpkgs/issues/210210
    # - for containers we currently rely on the `stage-2` init script that sets up our /etc
    initrd.systemd.enable = lib.mkDefault (!config.boot.swraid.enable && !config.boot.isContainer);
    # Not really necessary with impermanence, but should always be done anyway
    tmp.cleanOnBoot = true;
    zfs.forceImportRoot = false;
    loader = {
      systemd-boot = {
        enable = true;
        memtest86.enable = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };
}
