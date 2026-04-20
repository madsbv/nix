{
  lib,
  pkgs,
  ...
}:

{
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
