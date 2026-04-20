{ moduleCollections, ... }:

{
  imports = [
    ./configuration.nix
  ]
  ++ moduleCollections.base-nixos
  ++ moduleCollections.nixos-server
  ++ moduleCollections.nixos-client;
}
