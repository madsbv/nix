{
  user,
  inputs,
  pkgs,
  nox,
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
        noto-fonts-emoji
      ]
      ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
  };
}
