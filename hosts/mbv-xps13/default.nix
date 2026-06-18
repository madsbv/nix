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
    laptop.enable = true;
    server.homeAssistant.enable = true;
  };
}
