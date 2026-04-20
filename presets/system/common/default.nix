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
      enableLocalBuilder = true;
      enableRemoteBuilders = true;
      # Enable all servers other than this one as remote builders
      # TODO: Figure out how to check which servers are online before trying to use them as build hosts, or reduce the timeout for ssh-ng connections.
      remoteBuilders_x86-64 = nodes.buildMachines;
      inherit hostname;
    };
    neovim.enable = true;
    keys = {
      enable = true;
    };
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

  virtualisation = {
    podman.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        vhostUserPackages = [ pkgs.virtiofsd ];
      };
    };
    # NOTE: Gives users arbitrary USB access, should not be enabled on servers
    # spiceUSBRedirection.enable = true;
  };
}
