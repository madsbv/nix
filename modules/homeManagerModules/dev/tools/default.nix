{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.tools;
in
{
  options.local.dev.tools.enable = lib.mkEnableOption "Development tools";

  config = lib.mkIf cfg.enable {
    programs = {
      fd = {
        enable = true;
        hidden = true;
        ignores = [ ".git/" ];
      };
      git = {
        enable = true;
        lfs = {
          enable = true;
        };
      };
      direnv = {
        enable = true;
        nix-direnv.enable = true;
      };
    };
    home.packages = with pkgs; [
      devenv
      # Good to just have generally available
      hyperfine
      # Misc language servers
      yaml-language-server
      sqls
      lua-language-server
      vscode-langservers-extracted
    ];
  };
}
