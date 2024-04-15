{ flake-root, hostname, ... }:

let
  modules = flake-root + "/modules";
in
{
  imports = [
    # Generalizable config should be in default.nix, machine-specific stuff should be in configuration.nix and hardware-configuration.nix
    ./configuration.nix
    (modules + "/nixos/server")
  ];

  local.server = {
    inherit hostname;
  };

  services.ollama = {
    enable = true;
    acceleration = "cuda";
    # The default, repeated for documentation
    listenAddress = "127.0.0.1:11434";
    models = "/var/lib/ollama/models";
  };
  local.restic.exclude = [ "/var/lib/ollama/models" ];
}
