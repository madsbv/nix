{
  config,
  lib,
  pkgs,
  my-doomemacs-config,
  doomemacs,
  ...
}:
let
  cfg = config.local.emacs;
in
{
  options.local.emacs = {
    enable = lib.mkEnableOption "Emacs";
    package = lib.mkPackageOption pkgs "emacs" { };
    doomConfigRepo = lib.mkOption {
      default = "https://github.com/madsbv/doom.d.git";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = lib.mkIf config.local.hm.enable [
      (
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

            home = {
              activation.installDoomEmacs = lib.mkIf config.local.doomemacs.enable (
                lib.hm.dag.entryAfter [ "writeBoundary" ] ''
                  if [ ! -d "${doomDir}" ]; then
                      ${pkgs.git}/bin/git clone ${cfg.doomConfigRepo} "${doomDir}"
                  fi
                  if [ ! -d "${emacsDir}" ]; then
                      ${pkgs.rsync}/bin/rsync -avz --chmod=D2755,F744 "${doomemacs}"/ "${emacsDir}"
                      ${emacsDir}/bin/doom install
                  fi
                ''
              );
              # To make doom binary available
              sessionPath = [ "${emacsDir}/bin" ];
            };
          };
        }
      )
    ];
    environment.systemPackages = with pkgs; [
      # Misc Doomemacs dependencies
      coreutils-prefixed # Mostly for GNU ls on Darwin
      cmake
      pinentry-emacs # 2024-03-18: The pinentry packages has been split up into multiple different packages exposing the different frontends. pinentry-emacs should expose the emacs, curses and tty frontends, but not the gtk and qt frontends which require linux.
    ];
  };
}
