{
  user,
  nox,
  pkgs,
  mod,
  ...
}:

{
  imports = [
    (mod "system/common/common")
    (mod "dev")
    (mod "editor")
    ./secrets/email.nix
  ];

  local.emacs.enable = true;

  home-manager = {
    sharedModules = [
      (
        { ... }:
        {
          imports = [ (mod "home-manager/common/client") ];
          local.doomemacs.enable = true;
        }
      )
    ];
    extraSpecialArgs = {
      inherit user nox;
    };
  };

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
