{ ... }:

{
  imports = [
    ./configuration.nix
    ../../presets/system/common
    ../../presets/system/home-manager
    ../../presets/nixos/common
    ../../presets/nixos/efi
  ];

  local = {
    # Extremely slow laptop (Intel Celeron N1000)
    builder.enableLocalBuilder = false;
  };

  # Use for networking? E.g. ad blocking local DNS server
}
