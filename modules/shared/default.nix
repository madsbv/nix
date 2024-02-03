{ config, pkgs, ... }:

let emacsOverlaySha256 = "06413w510jmld20i4lik9b36cfafm501864yq8k4vxl5r4hn0j0h";
in {

  nixpkgs = {
    config = {
      # TODO: Turn off allowBroken and allowUnsupported, and see how many packages I currently have installed that are either of those.
      allowUnfree = true;
      allowBroken = true;
      allowInsecure = false;
      allowUnsupportedSystem = true;
    };
    # TODO: Look through overlays, consider whether to use emacs-overlay. Install Doom.
    overlays =
      # Apply each overlay found in the /overlays directory
      let path = ../../overlays;
      in with builtins;
      map (n: import (path + ("/" + n))) (filter (n:
        match ".*\\.nix" n != null
        || pathExists (path + ("/" + n + "/default.nix")))
        (attrNames (readDir path)));

      #++ [
      #  (import (builtins.fetchTarball {
      #    url =
      #      "https://github.com/dustinlyons/emacs-overlay/archive/refs/heads/master.tar.gz";
      #    sha256 = emacsOverlaySha256;
      #  }))
      #];
  };
}
