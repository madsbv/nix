{
  lib,
  config,
  pkgs,
  flake-root,
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
    remoteBuilders_x86-64 = lib.mkOption { default = [ ]; };
    hostname = lib.mkOption {
      description = "The hostname of this machine, to be excluded from the list of buildmachines";
    };
  };

  config = {
    users = lib.mkIf cfg.enableLocalBuilder {
      users.builder =
        {
          openssh.authorizedKeys.keyFiles = [
            (builtins.readFile "${flake-root}/pubkeys/ssh/id_ed25519.mbv-mba.mvilladsen.pub")
            (builtins.readFile "${flake-root}/pubkeys/ssh/id_ed25519.mbv-workstation.mvilladsen.pub")
          ];
        }
        // lib.mkIf pkgs.stdenv.isLinux {
          isSystemUser = true;
          group = "builders";
        }
        // lib.mkIf pkgs.stdenv.isDarwin {
          isHidden = false;
          uid = 42;
          gid = 42;
          home = "/var/nix-builder";
        };
      # nix-darwin does not have users.users.<name>.group option, only gid option, so set here as well.
      groups.builders = {
        members = [ "builder" ];
        gid = 42;
      };
    };

    # TODO: Somehow make this a map over all nodes with enableLocalBuilder set. Not sure how automated we can make this? Maybe deploy-rs will help?
    # We could of course declare this on the top level
    nix.buildMachines = lib.mkIf cfg.enableRemoteBuilders (
      builtins.filter (builder: builder.hostName != cfg.hostname) (
        map (builderHostname: {
          # sshKey = config.age.secrets.ssh-user-mbv-mba.path; # I'm pretty sure we don't need this with Tailscale
          system = "x86_64-linux";
          sshUser = "builder";
          hostName = builderHostname; # Tailscale
          # Might be necessary for tailscale connections
          protocol = "ssh-ng";
          supportedFeatures = [
            "kvm"
            "big-parallel"
            "benchmark"
          ];
          maxJobs = 8;
        }) cfg.remoteBuilders_x86-64

        ++ [
          {
            system = "aarch64-darwin";
            sshUser = "mvilladsen";
            hostName = "mbv-mba";
            protocol = "ssh-ng";
            supportedFeatures = [
              "kvm"
              "big-parallel"
              "benchmark"
            ];
            maxJobs = 8;
          }
        ]
      )
    );
    # Fix annoyance where unavailable remote builders cause significant delay in starting build
    programs.ssh.extraConfig = lib.mkIf cfg.enableRemoteBuilders (
      # SSH connection timeout in seconds
''
      ConnectTimeout = 10
      ServerAliveInterval = 5
      ServerAliveCountMax = 2
''
    );
  };
}
