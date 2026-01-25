{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.lua;
in
{
  options.local.dev.lua.enable = lib.mkEnableOption "Lua";

  config = lib.mkIf cfg.enable {
    home.packages =
      (with pkgs; [
        luajit
        lua-language-server
      ])
      ++ (with pkgs.luajitPackages; [
        luarocks
      ]);
    home.sessionVariables = {
      LUA_LANGUAGE_SERVER_INSTALL_DIR = "${pkgs.lua-language-server}";
    };
  };
}
