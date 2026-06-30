{
  config,
  lib,
  nodes ? { clients = [ ]; servers = [ ]; },
  flake-root,
  ...
}:

let
  cfg = config.local.keys;
in
{
  options.local.keys = {
    enable = lib.mkEnableOption "SSH known hosts for known services and flake nodes";
    enable_authorized_access = lib.mkEnableOption "key-authenticated SSH access for authorized users";
    hostKeyDir = lib.mkOption {
      type = lib.types.str;
      default = "${flake-root}/pubkeys/ssh";
      description = "Directory containing host SSH public keys named ssh_host_ed25519_key.pub.<hostname>";
    };
    authorized_users = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = lib.mapAttrsToList (_: u: u.username)
        (lib.filterAttrs (_: u: u.isAuthorized) (builtins.removeAttrs config.local.users [ "enable" ]));
      description = "Users to receive SSH authorized_keys access";
    };
    authorized_user_keys = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ ];
      description = "SSH public key strings to add to authorized_users";
    };
  };

  config.programs.ssh.knownHosts = lib.mkIf cfg.enable (
    {
      "github.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOMqqnkVzrm0SdG6UOoqKLsabgH5C9okWi0dh2l9GKJl";
      "gitlab.com".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAfuCHKVTjquxvt6CM6tdG4SLp1Btn/nOeHHE5UOzRdf";
      "git.sr.ht".publicKey =
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIMZvRd4EtM7R+IHVMWmDkVU3VLQTSwQDSAvW0t2Tkj60";
    }
    // builtins.listToAttrs (
      map (host: {
        name = host;
        value = {
          publicKeyFile = "${cfg.hostKeyDir}/ssh_host_ed25519_key.pub.${host}";
        };
      }) (nodes.clients ++ nodes.servers)
    )
  );

  config.users.users = lib.mkIf cfg.enable_authorized_access (
    lib.mergeAttrsList (
      map (user: { ${user}.openssh.authorizedKeys.keys = cfg.authorized_user_keys; }) cfg.authorized_users
    )
  );
}
