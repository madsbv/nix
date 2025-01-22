{ mod, ... }:

{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    (mod "system/nixos/server")
  ];

  local = {
    # Extremely slow laptop (Intel Celeron N1000)
    builder.enableLocalBuilder = false;
  };

  # Use for networking? E.g. ad blocking local DNS server
}
