{ pkgs }:

with pkgs;
let
  shared-packages = import ../shared/packages.nix { inherit pkgs; };
  # my-emacs = emacs29-macport.override {
  #   withNativeCompilation = true;
  #   withImageMagick = true;
  #   noTitlebarMac = true;
  # };
  my-emacs = emacs29-macport;
in shared-packages ++ [ dockutil pinentry_mac pngpaste ]
