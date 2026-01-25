{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.javascript;
in
{
  options.local.dev.javascript.enable = lib.mkEnableOption "JavaScript";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs.nodePackages; [
      nodejs
      typescript-language-server
      js-beautify
      # For yaml formatting, among other things
      prettier
      eslint
    ];
    programs.bun.enable = true;
  };
}
