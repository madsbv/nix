{
  flake-root,
  ...
}:

{
  nixpkgs = {
    config = {
      allowUnfree = true;
      allowBroken = false;
      # allowInsecure = false;
      permittedInsecurePackages = [ "electron-39.8.10" ];
      allowUnsupportedSystem = false;
      warnUndeclaredOptions = true;
    };

    overlays =
      # Apply each overlay found in the /overlays directory
      let
        path = flake-root + "/overlays";
      in
      with builtins;
      map (n: import (path + ("/" + n))) (
        filter (n: match ".*\\.nix" n != null || pathExists (path + ("/" + n + "/default.nix"))) (
          attrNames (readDir path)
        )
      );
  };
}
