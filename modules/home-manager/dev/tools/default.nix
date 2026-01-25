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
    home.packages = with pkgs; [
      devenv
      # Good to just have generally available
      gcc
      clang
      llvm
      hyperfine
      # Misc language servers
      yaml-language-server
      sqls
      lua-language-server
      vscode-langservers-extracted
    ];
  };
}
