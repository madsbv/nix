{
  flake-root,
  nodes,
  config,
  lib,
  ...
}:

let
  cfg = config.local.keys;
  pubHostKeyPath = flake-root + "/pubkeys/ssh";
  getPubHostKey = host: pubHostKeyPath + "/ssh_host_ed25519_key.pub.${host}";
in
{
  options.local.keys = {
    enable = lib.mkEnableOption "Set SSH knownHosts.";
    enable_authorized_access = lib.mkOption {
      description = "Allow key-authenticated SSH access to users config.local.keys.authorized_users";
      default = false;
    };
    authorized_users = lib.mkOption {
      description = "Users to allow key-authenticated access for.";
      default = [ "mvilladsen" ];
    };
    authorized_user_keys = lib.mkOption {
      description = "List of public keys for the authorized user.";
      default = [
        (builtins.readFile "${flake-root}/pubkeys/ssh/id_ed25519.mbv-mba.mvilladsen.pub")
        (builtins.readFile "${flake-root}/pubkeys/ssh/id_ed25519.mbv-workstation.mvilladsen.pub")
      ];
    };
  };

  config.programs.ssh.knownHosts = lib.mkIf cfg.enable (
    {
      # From https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/githubs-ssh-key-fingerprints
      "github.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
    }
    // builtins.listToAttrs (
      map (host: {
        name = host;
        value = {
          publicKeyFile = getPubHostKey host;
        };
      }) (nodes.clients ++ nodes.servers)
    )
  );

  # Allow access to given users with given keys
  # This will create the user, but will not give it any useful permissions in isolation.
  config.users.users = lib.mkIf cfg.enable_authorized_access (
    lib.mergeAttrsList (
      map (user: { ${user}.openssh.authorizedKeys.keys = cfg.authorized_user_keys; }) cfg.authorized_users
    )
  );
}
