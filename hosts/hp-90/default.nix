{ hostname, mod, ... }:

{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    (mod "nixos/server")
    (mod "shared/secrets/wifi.nix")
  ];

  local = {
    server = {
      inherit hostname;
    };
    # Extremely slow laptop (Intel Celeron N1000)
    builder.enableLocalBuilder = false;
  };

  services = {
    # TODO: Configure
    # Available on hp-90:8123
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
        "jellyfin"
        "seventeentrack"
        "speedtestdotnet"
      ];
      config.homeassistant = {
        # TODO: Update for US
        name = "ha-name";
        latitude = 0.0;
        longitude = 0.0;
        time_zone = "Europe/Berlin";
        unit_system = "metric";
        temperature_unit = "C";
      };
    };

    # Available on hp-90:8096
    # Will this laptop be powerful enough?
    jellyfin.enable = true;

    # TODO: Configure
    # Available on hp-90:9091
    transmission.enable = true;

    # See https://www.reddit.com/r/NixOS/comments/12ibbl9/protonvpn_nixos_setup/ for potential protonvpn nixos integration options
  };
}
