{
  config,
  lib,
  pkgs,
  inputs,
  color-scheme,
  ...
}:

{

  # Currently used for Kitty and Alacritty only
  imports = [ inputs.base16.homeManagerModule ];
  scheme = color-scheme;
  xdg.enable = true;
  home = {
    stateVersion = "23.11";
    preferXdgDirectories = true;
  };
  local = {
    emacs.enable = lib.mkDefault true;
    dev.enable = true;
  };
}
