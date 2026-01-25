{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.fortran;
in
{
  options.local.dev.fortran.enable = lib.mkEnableOption "Fortran";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      fortls
      gfortran
      fpm
      fprettify
    ];
  };
}
