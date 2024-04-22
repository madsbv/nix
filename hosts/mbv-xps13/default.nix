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
    # Available on mbv-xps13:8123
    home-assistant = {
      enable = true;
      configWritable = true;
      extraComponents = [
        "awair"
        "accuweather"
        "tailscale"
        # Supposedly for Smart Life
        # See also https://github.com/rospogrigio/localtuya
        "tuya"
        "wake_on_lan"
        "plex"
        "seventeentrack"
        "speedtestdotnet"
      ];
      config.homeassistant = {
        name = "Berlin";
        latitude = 0.0;
        longitude = 0.0;
        time_zone = "Europe/Berlin";
        unit_system = "metric";
        temperature_unit = "C";
      };
    };

    # TODO: Configure
    # Available on mbv-xps13:32400/web
    plex.enable = true;

    # Available on mbv-xps13:9091
    transmission.enable = true;

    # See https://www.reddit.com/r/NixOS/comments/12ibbl9/protonvpn_nixos_setup/ for potential protonvpn nixos integration options
  };
}
