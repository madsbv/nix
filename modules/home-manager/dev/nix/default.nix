{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.nix;
in
{
  options.local.dev.nix.enable = lib.mkEnableOption "Nix";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nixfmt-rfc-style
      nil
      deadnix
      statix
    ];
  };
}
