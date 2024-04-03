{ config, lib, pkgs, ... }:

let cfg = config.srvos;
in {
  options.srvos = {
    flake = lib.mkOption {
      type = lib.types.nullOr lib.types.raw;
      default = null;
      description = lib.mdDoc ''
        Flake that contains the nixos configuration.
      '';
    };

    symlinkFlake = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.isLinux;
      description = lib.mdDoc ''
        Symlinks the flake the system was built with to `/run/current-system`
        Having access to the flake the system was installed with can be useful for introspection.

        i.e. Get a development environment for the currently running kernel

        ```
        $ nix develop "$(realpath /run/booted-system/flake)#nixosConfigurations.turingmachine.config.boot.kernelPackages.kernel"
        $ tar -xvf $src
        $ cd linux-*
        $ zcat /proc/config.gz  > .config
        $ make scripts prepare modules_prepare
        $ make -C . M=drivers/block/null_blk
        ```

        Set this option to false if you want to avoid uploading your configuration to every machine (i.e. in large monorepos)
      '';
    };

    upgradeDiff = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.isLinux;
      description = lib.mdDoc ''
        Shows a diff between the current system and the new configuration.
      '';
    };
  };

  config = lib.mkIf (cfg.flake != null) {
    system.activationScripts.symlinkFlake =
      lib.optionalString cfg.symlinkFlake ''
        ln -s ${cfg.flake} /etc/nixos/current-system
      '';

    # MIT Jörg Thalheim - https://github.com/Mic92/dotfiles/blob/c6cad4e57016945c4816c8ec6f0a94daaa0c3203/nixos/modules/upgrade-diff.nix
    system.activationScripts.upgradeDiff = lib.mkIf cfg.upgradeDiff {
      supportsDryActivation = true;
      text = ''
        if [[ -e /run/current-system ]]; then
          echo "--- diff to current-system"
          ${pkgs.nvd}/bin/nvd --nix-bin-dir=${config.nix.package}/bin diff /run/current-system "$systemConfig"
          echo "---"
        fi
      '';
    };
  };
}
