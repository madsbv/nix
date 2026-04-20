{ moduleCollections, ... }:

{
  imports = [ ./configuration.nix ] ++ moduleCollections.base-nixos ++ moduleCollections.nixos-server;

  local = {
    # Extremely slow laptop (Intel Celeron N1000)
    builder.enableLocalBuilder = false;
  };

  # Use for networking? E.g. ad blocking local DNS server
}
