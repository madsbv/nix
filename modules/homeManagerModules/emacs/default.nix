{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.local.emacs;
in
{
  options.local.emacs = {
    enable = lib.mkEnableOption "Emacs";
    package = lib.mkPackageOption pkgs "my-emacs" { };
    doomemacs = {
      enable = lib.mkEnableOption "Doomemacs" // {
        default = cfg.enable;
      };
      repo = lib.mkOption {
        default = "https://github.com/doomemacs/doomemacs.git";
      };
      configRepo = lib.mkOption {
        default = "https://github.com/madsbv/personal-doom.git";
      };
    };
  };

  config = lib.mkIf cfg.enable (
    let
      emacsDir = "${config.xdg.configHome}/emacs";
      doomDir = "${config.xdg.configHome}/doom";
    in
    {
      programs.emacs = lib.mkIf cfg.enable {
        inherit (cfg) enable package;
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

      home = lib.mkIf cfg.doomemacs.enable {
        activation.installDoomEmacs = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d "${doomDir}" ]; then
              ${pkgs.git}/bin/git clone ${cfg.doomemacs.configRepo} "${doomDir}"
              ${pkgs.git}/bin/git -C "${doomDir}" submodule update --init --recursive
          fi
          if [ ! -d "${emacsDir}" ]; then
              ${pkgs.git}/bin/git clone ${cfg.doom.repo} "${emacsDir}"
              ${emacsDir}/bin/doom install
          fi
        '';
        # To make doom binary available
        sessionPath = [ "${emacsDir}/bin" ];
      };
    }
  );
}
