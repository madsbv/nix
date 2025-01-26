{
  pkgs,
  ...
}:

{
  environment = {
    systemPackages =
      (with pkgs; [
        luajit
        lua-language-server
      ])
      ++ (with pkgs.luajitPackages; [
        luarocks
      ]);
    variables = {
      LUA_LANGUAGE_SERVER_INSTALL_DIR = "${pkgs.lua-language-server}";
    };
  };

}
