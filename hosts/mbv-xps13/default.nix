{ hostname, mod, ... }:

{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    (mod "nixos/server")
    (mod "shared/secrets/wifi.nix")
  ];

  local.server = {
    inherit hostname;
  };

  services = {
    # TODO: Configure
    home-assistant = {
      enable = true;
      configWritable = true;
      config.homeassistant = {
        name = "Goltzstrasse";
        latitude = 0.0;
        longitude = 0.0;
        time_zone = "Europe/Amsterdam";
        unit_system = "metric";
        temperature_unit = "C";
      };
    };

    # TODO: How to use?
    # Temporarily turned off.
    plex.enable = true;
  };
}
