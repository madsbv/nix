{
  inputs,
  pkgs,
  nox,
  mod,
  lib,
  modules,
  ...
}:
let
  user = "mvilladsen";
in
{
  imports = [
    (mod "system/common/common")
    (mod "editor")
    ./secrets/email.nix
  ];

  local.emacs.enable = lib.mkDefault true;

  home-manager = {
    users.${user} = {
      imports = [
        (mod "home-manager/common/client")
        modules.home-manager.dev.all
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

  fonts = {
    packages =
      with pkgs;
      [
        dejavu_fonts
        emacs-all-the-icons-fonts
        jetbrains-mono
        feather-font # from overlay
        font-awesome
        hack-font
        meslo-lgs-nf
        noto-fonts
        noto-fonts-color-emoji
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };
}
