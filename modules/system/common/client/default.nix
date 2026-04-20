{
  inputs,
  pkgs,
  nox,
  lib,
  modules,
  ...
}:
let
  user = "mvilladsen";
in
{
  home-manager = {
    users.${user} = {
      imports = [
        modules.home-manager.common-client
        modules.home-manager.dev-all
      ];
      local = {
        doomemacs.enable = lib.mkDefault true;
        dev.enable = true;
      };
    };
    extraSpecialArgs = {
      inherit user inputs nox;
    };
  };

}
