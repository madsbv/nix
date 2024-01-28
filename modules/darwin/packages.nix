{ pkgs }:

with pkgs;
let shared-packages = import ../shared/packages.nix { inherit pkgs; };
in shared-packages ++ [
  dockutil
  pinentry_mac
  pngpaste
  # Uncomment after switching over from homebrew
  # emacs29-macport = self.emacs29.override {
  #   withNativeCompilation = true;
  #   withImageMagick = true;
  # };
]
