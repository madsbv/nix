{ flake-root, config, ... }:

{
  age.secrets = {
    spiderlan-nm = {
      rekeyFile = flake-root + "/secrets/other/spiderlan.nmconnection.age";
    };
    att-nm = {
      rekeyFile = flake-root + "/secrets/other/ATTDg2Kv45.nmconnection.age";
    };
    synapse-nm = {
      rekeyFile = flake-root + "/secrets/other/Synapse.nmconnection.age";
    };
    vindbjerggaard = {
      rekeyFile = flake-root + "/secrets/other/Vindbjerggaard.nmconnection.age";
    };
  };
  # Networkmanager has the option ensureProfile which could handle this in a nicer way, but that would leak secrets.
  # https://nixos.org/manual/nixos/stable/options#opt-networking.networkmanager.ensureProfiles.profiles
  environment.etc = {
    "NetworkManager/system-connections/spiderlan.nmconnection".source =
      config.age.secrets.spiderlan-nm.path;
    "NetworkManager/system-connections/att.nmconnection".source = config.age.secrets.att-nm.path;
    "NetworkManager/system-connections/synapse.nmconnection".source =
      config.age.secrets.synapse-nm.path;
    "NetworkManager/system-connections/vindbjerggaard.nmconnection".source = config.age.secrets.vindbjerggaard.path;
  };
}
