{ flake-root, hostname, ... }:

let
  modules = flake-root + "/modules";
in
{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    (modules + "/nixos/server")
  ];

  local.server = {
    inherit hostname;
  };
}
