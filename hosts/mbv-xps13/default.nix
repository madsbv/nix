{ mod, ... }:

{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    (mod "system/nixos/server")
    (mod "services/home-assistant")
    (mod "system/nixos/common/laptop.nix")
  ];

  services = {
    # Available on mbv-xps13:8096
    jellyfin.enable = true;

    # TODO: Configure
    # Available on mbv-xps13:9091
    transmission.enable = true;

    # See https://www.reddit.com/r/NixOS/comments/12ibbl9/protonvpn_nixos_setup/ for potential protonvpn nixos integration options
  };
}
