{
  flake-root,
  hostname,
  nodes,
  lib,
  config,
  pkgs,
  ...
}:

{
  imports = [
    ./terminfo.nix
    ./keys.nix
    ./nix.nix
    ./nixpkgs.nix
    ./terminfo.nix
  ];

  local = {
    builder = {
      remoteBuilders_x86-64 = nodes.buildMachines;
      inherit hostname;
    };
    keys.enable = true;
  };

  environment = {
    # nix-darwin has its own mechanism for this
    etc = lib.mkIf pkgs.stdenv.isLinux (
      lib.mapAttrs' (name: value: {
        name = "nix/path/${name}";
        value.source = value.flake;
      }) config.nix.registry
    );
    systemPackages = import ./system-packages.nix { inherit pkgs; };
  };
}
