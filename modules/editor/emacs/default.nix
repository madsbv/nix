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
  };

  config = lib.mkIf cfg.enable {
    home-manager.sharedModules = lib.mkIf config.local.hm.enable [
      (import ./hm.nix {
        inherit (cfg) package;
        enableEmacs = cfg.enable;
        inherit my-doomemacs-config doomemacs;
      })
    ];
    environment.systemPackages = with pkgs; [
      # Misc Doomemacs dependencies
      coreutils-prefixed # Mostly for GNU ls on Darwin
      cmake
      pinentry-emacs # 2024-03-18: The pinentry packages has been split up into multiple different packages exposing the different frontends. pinentry-emacs should expose the emacs, curses and tty frontends, but not the gtk and qt frontends which require linux.
    ];
  };
}
