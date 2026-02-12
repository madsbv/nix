{ moduleCollections, ... }:

{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
  ]
  ++ (with moduleCollections; [
    base-nixos
    nixos-server
    nixos-client
  ])
  ++ (with moduleCollections.services; [
    home-assistant
  ]);
}
