{ ... }:

{
  imports = [
    ./configuration.nix
    ../../presets/system/common
    ../../presets/system/home-manager
    ../../presets/nixos/common
    ../../presets/nixos/efi
    ../../presets/system/yubikey-agenix-rekey
  ];

  local = {
    # Extremely slow laptop (Intel Celeron N1000)
    builder.enableLocalBuilder = false;
  };

  # Use for networking? E.g. ad blocking local DNS server
}
