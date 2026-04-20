{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.srvos;
in
{
  options.srvos = {
    flake = lib.mkOption {
      # FIXME what is the type of a flake?
      type = lib.types.nullOr lib.types.raw;
      default = null;
      description = ''
        Flake that contains the nixos configuration.
      '';
    };

    registerSelf = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Add the flake the system was built with to `nix.registry` as `self`.
        Having access to the flake the system was installed with can be useful for introspection.

        i.e. Get a development environment for the currently running kernel

        ```
        $ nix develop self#nixosConfigurations.turingmachine.config.boot.kernelPackages.kernel
        $ tar -xvf $src
        $ cd linux-*
        $ zcat /proc/config.gz  > .config
        $ make scripts prepare modules_prepare
        $ make -C . M=drivers/block/null_blk
        ```

        Set this option to false if you want to avoid uploading your configuration to every machine (i.e. in large monorepos)
      '';
    };

  };
  config = lib.mkIf (cfg.flake != null) {
    nix.registry = lib.optionalAttrs cfg.registerSelf {
      self.to = lib.mkDefault {
        type = "path";
        path = cfg.flake;
      };
    };
  };
}
