{ mod, hostname, ... }:

let
  user = "mvilladsen";
in
{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    ./gui.nix
    (mod "nixos/server")
    (mod "shared/secrets/wifi.nix")
  ];

  local = {
    server = {
      inherit hostname;
    };
    # This machine is already plenty fast, let's save some complication
    builder.enableRemoteBuilders = false;
  };

  environment.persistence."/nix/persist".directories = [
    {
      directory = "/home/${user}";
      user = user;
      mode = "u=rwx,g=rx,o=";
    }
  ];

  nixpkgs.config = {
    rocmSupport = true;
  };

  services.ollama = {
    enable = true;
    # Should really be "cuda", but we currently get a collision.
    # I think it's related to the 'fixme' in: https://github.com/NixOS/nixpkgs/blob/bad6d5d22e7c6502d147f19b20bbbf759c5ee558/pkgs/tools/misc/ollama/default.nix#L27
    # acceleration = false;
    # The default, repeated for documentation
    # listenAddress = "0.0.0.0:11434";
    # host = "0.0.0.0";
    # port = "11434";
    models = "/var/lib/ollama/models";
    home = "/var/lib/ollama";
  };
  local.restic.exclude = [ "/var/lib/ollama/models" ];
}
