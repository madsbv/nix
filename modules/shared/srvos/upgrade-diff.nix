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
      type = lib.types.nullOr lib.types.raw;
      default = null;
      description = lib.mdDoc ''
        Flake that contains the nixos configuration.
      '';
    };

    upgradeDiff = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = lib.mdDoc ''
        Shows a diff between the current system and the new configuration.
      '';
    };
  };

  config = lib.mkIf (cfg.flake != null) {
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
