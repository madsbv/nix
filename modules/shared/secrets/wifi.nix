{ flake-root, config, ... }:

{
  age.secrets = {
    home-wifi-nm = {
      rekeyFile = flake-root + "/secrets/other/home-wifi.nmconnection.age";
    };
  };
  # Networkmanager has the option ensureProfile which could handle this in a nicer way, but that would leak secrets.
  # https://nixos.org/manual/nixos/stable/options#opt-networking.networkmanager.ensureProfiles.profiles
  environment.etc."NetworkManager/system-connections/home-wifi.nmconnection".source =
    config.age.secrets.home-wifi-nm.path;
}
