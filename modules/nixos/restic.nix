{
  config,
  lib,
  flake-root,
  ...
}:

# Goal: Write a general purpose module for backing up nixos machines with impermanence. By default, we will back up everything in the persistent storage directory, allowing the consumer of this module to set that path and to add excludes. General config like repository, keys, timers, global options will be set here.
let
  cfg = config.local.restic;
in
{
  options.local.restic = {
    enable = lib.mkOption { default = true; };
    paths = lib.mkOption { default = [ "/nix/persist" ]; };
    exclude = lib.mkOption { default = [ ]; };
  };

  config.services.restic.backups.persist = lib.mkIf cfg.enable {
    # inherit (cfg) exclude paths;
    paths = cfg.paths;
    exclude = cfg.exclude;

    createWrapper = true;

    environmentFile = config.age.secrets.restic-env.path;
    passwordFile = config.age.secrets.restic-password.path;
    repositoryFile = config.age.secrets.restic-repo.path;
    # TODO: Do we actually need these?
    # rcloneConfig = null;
    # rcloneConfigFile = null; # For encryption key?
    # rcloneOptions = null;

    timerConfig = {
      OnCalendar = "daily";
      Persistent = true;
    };

    pruneOpts = [
      "--keep-last 14"
      "--keep-daily 14"
      "--keep-weekly 10"
      "--keep-monthly 12"
      "--keep-yearly 10"
    ];
  };

  config.age.secrets = lib.mkIf cfg.enable {
    restic-env.rekeyFile = flake-root + "/secrets/restic/env.age";
    restic-repo.rekeyFile = flake-root + "/secrets/restic/repo.age";
    restic-password.rekeyFile = flake-root + "/secrets/restic/password.age";
  };
}
