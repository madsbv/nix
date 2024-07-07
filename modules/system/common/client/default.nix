{ pkgs, mod, ... }:

{
  imports = [
    (mod "system/common/common")
    (mod "dev")
    (mod "editor")
    ./secrets/email.nix
  ];

  fonts = {
    packages = with pkgs; [
      dejavu_fonts
      emacs-all-the-icons-fonts
      jetbrains-mono
      feather-font # from overlay
      font-awesome
      hack-font
      meslo-lgs-nf
      nerdfonts
      noto-fonts
      noto-fonts-emoji
    ];
  };
}
