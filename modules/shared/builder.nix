{
  lib,
  config,
  pkgs,
  ...
}:
### Defines and sets minimal permissions for a "builder" user which other machines can SSH into via tailscale ssh (controlled by tailscale ACL). Should be written so it can be imported as-is into either a nix-darwin or nixos configuration.

let
  cfg = config.local.builder;
in
{
  options.local.builder = {
    enableLocalBuilder = lib.mkOption {
      description = "If true, create a local user with minimal permissions to act as access point for using this machine as a remote builder.";
      default = true;
    };
    enableRemoteBuilders = lib.mkOption {
      description = "Enable the use of other nodes as remote builders over Tailscale";
      default = true;
    };
  };

  config = {
    # Create builder user
    # Making this Darwin/NixOS agnostic is rather restrictive
    users = lib.mkIf cfg.enableLocalBuilder {
      users.builder = lib.mkIf pkgs.stdenv.isLinux {
        isSystemUser = true;
        group = "builder";
      };
      groups.builder = {
        members = [ "builder" ];
      };
    };

    # TODO: Somehow make this a map over all nodes with enableLocalBuilder set. Not sure how automated we can make this? Maybe deploy-rs will help?
    # We could of course declare this on the top level
    # TODO: Can we add mbv-mba to this list easily?
    nix.buildMachines = lib.mkIf cfg.enableRemoteBuilders [
      {
        # sshKey = config.age.secrets.ssh-user-mbv-mba.path; # I'm pretty sure we don't need this with Tailscale
        system = "x86_64-linux";
        sshUser = "mvilladsen";
        hostName = "mbv-desktop"; # Tailscale
        protocol = "ssh-ng";
        supportedFeatures = [
          "kvm"
          "big-parallel"
          "benchmark"
        ];
        maxJobs = 8;
      }
      {
        # sshKey = config.age.secrets.ssh-user-mbv-mba.path; # I'm pretty sure we don't need this with Tailscale
        system = "x86_64-linux";
        sshUser = "mvilladsen";
        hostName = "mbv-xps13"; # Tailscale
        protocol = "ssh-ng";
        supportedFeatures = [
          "kvm"
          "big-parallel"
          "benchmark"
        ];
        maxJobs = 8;
      }
    ];
  };
}
