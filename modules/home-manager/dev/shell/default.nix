{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.shell;
in
{
  options.local.dev.shell.enable = lib.mkEnableOption "Shell";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nodePackages.bash-language-server
      shellcheck
      shfmt
    ];
  };
}
