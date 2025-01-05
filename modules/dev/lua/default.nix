{
  pkgs,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      lua
      lua-language-server
    ];
    variables = {
      LUA_LANGUAGE_SERVER_INSTALL_DIR = "${pkgs.lua-language-server}";
    };
  };

}
