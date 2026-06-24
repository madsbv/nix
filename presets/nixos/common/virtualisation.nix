{
  pkgs,
  ...
}: {
  virtualisation = {
    podman.enable = true;
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        vhostUserPackages = [pkgs.virtiofsd];
      };
    };
  };
}
