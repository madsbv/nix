{
  lib,
  ...
}: let
  user = "mvilladsen";
in {
  imports = [
    ./sudo.nix
    ./nix.nix
    # ./zfs.nix (redundant — handled by nixosModules/common)
    ./update-diff.nix
    ../../system/yubikey-agenix-rekey
  ];

  local.common.enable = true;

  home-manager.sharedModules = [../../home-manager/nixos];

  local.restic.exclude = [
    "/nix/persist/var/lib/private/ollama"
    "/nix/persist/var/lib/libvirt/images"
    "/nix/persist/home/${user}/.local/share/Steam"
    "/nix/persist/home/${user}/Downloads"
    "/nix/persist/home/${user}/.cache"
  ];
}
