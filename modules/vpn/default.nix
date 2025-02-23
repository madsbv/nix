{
  config,
  flake-root,
  ...
}:

{
  networking.wg-quick = {
    interfaces = {
      protonvpn = {
        configFile = config.age.secrets.mbv-desktop-protonvpn.path;
        # TODO: Use the pre/post up/down commands to set up a network namespace for this/hook into the transmission module
      };
    };
  };

  age.secrets.mbv-desktop-protonvpn.rekeyFile = flake-root + "/secrets/protonvpn/mbv-desktop.wg.age";
}
