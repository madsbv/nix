{
  config,
  lib,
  flake-root,
  ...
}:

let
  cfg = config.local.restic;
  environmentFile = config.age.secrets.restic-env.path;
  passwordFile = config.age.secrets.restic-password.path;
  repositoryFile = config.age.secrets.restic-repo.path;

  # Storage optimization
  resticOpts = [
    # For storage cost and especially transfer cost reasons, better compression might have some benefits
    "--compression=max"
    # We have plenty of memory to work with on all machines, and upload should be fast enough. Default pack size is 16MiB
    "--pack-size=64"
  ];

  pruneSchedule = [
    "--keep-last 14"
    "--keep-daily 14"
    "--keep-weekly 10"
    "--keep-monthly 12"
    "--keep-yearly 10"
  ];
in
{
  options.local.restic = {
    enable = lib.mkEnableOption "Enable automatic Restic backups";
    paths = lib.mkOption { default = [ "/nix/persist" ]; };
    exclude = lib.mkOption { default = [ ]; };
    persistPath = lib.mkOption { default = "/nix/persist"; };
    persistCache = lib.mkEnableOption "Add the Restic cache directory to the set of directories persisted to cfg.persistPath.";
  };

  config = lib.mkIf cfg.enable {
    services.restic.backups = {

      # Job to do regular backups, but no cleanup or checking since those are expensive to run often.
      persist = {
        inherit (cfg) exclude paths;
        inherit environmentFile passwordFile repositoryFile;

        # Creates restic-persist in path
        createWrapper = true;

        extraBackupArgs = [
          # Don't backup directories containing a `CACHEDIR.TAG` file (like restic's own cache)
          "--exclude-caches=true"
          # Increase the number of files read in parallel from the default of 2 (especially useful on fast NVMe storage)
          "--read-concurrency=8"
          # We're running the backup headless, so there's no reason to show progress estimation
          "--no-scan"
        ] ++ resticOpts;

        # Set the default explicitly to avoid accidental pruning
        # This disables both `forget --prune` and `check` from running after backups.
        pruneOpts = [ ];

        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
        };
      };

      # Occasionally prune and optimize storage and run cached check.
      persist-prune = {
        inherit environmentFile passwordFile repositoryFile;

        # Explicitly disable taking backups
        paths = null;
        dynamicFilesFrom = null;

        # Run check with existing cache to lower network resource usage
        checkOpts = [ "--with-cache" ] ++ resticOpts;

        pruneOpts =
          pruneSchedule
          ++ [
            # Only compresses completely uncompressed data, so this doesn't recompress auto-compressed data using max compression.
            "--repack-uncompressed"
          ]
          ++ resticOpts;

        timerConfig = {
          # Run every Monday
          OnCalendar = "Mon";
          Persistent = true;
        };
      };

      # Run a thorough check
      persist-check = {
        inherit environmentFile passwordFile repositoryFile;

        # Explicitly disable taking backups
        paths = null;
        dynamicFilesFrom = null;

        # Don't use local cache to ensure that we check repo data, and additionally download 1G of random backup data and verify its integrity.
        checkOpts = [ ''--read-data-subset="1G"'' ] ++ resticOpts;

        # Only do minimal pruning
        pruneOpts = pruneSchedule ++ resticOpts;

        timerConfig = {
          # Run every Wednesday
          OnCalendar = "Wed";
          Persistent = true;
        };
      };
    };

    age.secrets = lib.mkIf cfg.enable {
      restic-env.rekeyFile = flake-root + "/secrets/restic/env.age";
      restic-repo.rekeyFile = flake-root + "/secrets/restic/repo.age";
      restic-password.rekeyFile = flake-root + "/secrets/restic/password.age";
    };

    environment.persistence.${cfg.persistPath}.directories = lib.mkIf cfg.persistCache [
      # Restic basically needs its cache to be able to run in a reasonable amount of time
      "/var/cache/restic-backups-persist"
    ];
  };
}
