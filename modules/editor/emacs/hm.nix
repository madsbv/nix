{
  package,
  enableEmacs,
  my-doomemacs-config,
  doomemacs,
}:
{
  config,
  lib,
  pkgs,
  ...
}:
let
  emacsDir = "${config.xdg.configHome}/emacs";
  doomDir = "${config.xdg.configHome}/doom";
in
{
  # Option available from home manager to control whether to install doomemacs and my config files
  options.local.doomemacs.enable = lib.mkEnableOption "Doomemacs";

  config = {
    programs.emacs = {
      inherit package;
      enable = enableEmacs;
      extraPackages =
        epkgs: with epkgs; [
          # Packages that pull in non-lisp stuff
          # The mu4e epkg also pulls in the mu binary
          mu4e
          treesit-grammars.with-all-grammars
          vterm
          multi-vterm
          pdf-tools
        ];
    };

    home.activation.installDoomEmacs = lib.mkIf config.local.doomemacs.enable (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        if [ ! -d "${doomDir}" ]; then
           ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 ${my-doomemacs-config}/ ${doomDir}
        fi
        if [ ! -d "${emacsDir}" ]; then
           ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 "${doomemacs}"/ "${emacsDir}"
           ${emacsDir}/bin/doom install
        fi
      ''
    );
  };
}
