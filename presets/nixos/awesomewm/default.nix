{
  ...
}:

let
  user = "mvilladsen";
in
{
  home-manager = {
    users.${user} = {
      imports = [
        { local.awesomewm.enable = true; }
      ];
    };
  };
  services.xserver = {
    enable = true;
    windowManager.awesome = {
      enable = true;
      luaModules = [ ];
    };
  };
}
