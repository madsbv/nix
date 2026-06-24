{
  config,
  lib,
  ...
}: {
  imports = [
    ./sudo.nix
    ./nix.nix
    # ./zfs.nix (redundant — handled by nixosModules/common)
    ./update-diff.nix
    ./virtualisation.nix
    ../../system/yubikey-agenix-rekey
  ];

  local.common.enable = true;

  home-manager = {
    sharedModules = [../../home-manager/nixos ../../home-manager/common];
    users.root.home.stateVersion = "23.11";
  };

  local.restic.exclude = [
    "/nix/persist/var/lib/private/ollama"
    "/nix/persist/var/lib/libvirt/images"
    "/nix/persist/home/${config.local.users.primaryUser}/.local/share/Steam"
    "/nix/persist/home/${config.local.users.primaryUser}/Downloads"
    "/nix/persist/home/${config.local.users.primaryUser}/.cache"
  ];
}
