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
    laptop.enable = true;
    server.homeAssistant.enable = true;
  };
}
