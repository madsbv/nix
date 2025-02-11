{
  config,
  lib,
  flake-root,
  hostname,
  ...
}:

let
  cfg = config.local.restic;
  environmentFile = config.age.secrets.restic-env.path;
  passwordFile = config.age.secrets.restic-password.path;
  repositoryFile = config.age.secrets.restic-repo.path;

  hc-sh = config.age.secrets.healthchecks-sh.path;

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
        # TODO: Add initialize=true and confirm backups actually happen.

        initialize = true;
        inhibitsSleep = true;

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
          # Add as much random delay as reasonably possible, to reduce the risk of multiple machines trying to access the repo simultaneously, or of backup runs and a check or prune run running at the same time.
          RandomizedDelaySec = "20h";
        };
      };
      # Structure of healthchecks.io requests and secrets:
      # Have a script which takes a string input. The script should contain my healthchecks.io slug, prepend the given string, and make a request.
      # This way we can make the script a secret, and have the backupCleanupCommand and backupPrepareCommand type parameters just be a script that calls the secret script with the right hostname/check name/parameters.
      # If we append the query paramenter `?create=1`, a check will be created if it doesn't already exist.

      # Corresponds to the ExecStartPre parameter of systemd.
      # These commands must run successfully before the service is started (unless prefixed with `-`).
      # Could be used to check repo status, or for healthchecks.io timing metrics.
      # backupPrepareCommand = ''${hc-sh} "${hostname}-restic-backup/start?create=1"'';

      ## From the systemd.service manpages: https://www.freedesktop.org/software/systemd/man/latest/systemd.service.html
      # Note that all commands that are configured with this setting are invoked with the result code of the service, as well as the main process' exit code and status, set in the $SERVICE_RESULT, $EXIT_CODE and $EXIT_STATUS environment variables, see systemd.exec(5) for details.
      # In particular, we can use these for healthcheck calls.
      # backupCleanupCommand = ''${hc-sh} "${hostname}-restic-backup/$EXIT_CODE"'';

      # Occasionally prune and optimize storage and run cached check.
      persist-prune = {
        inherit environmentFile passwordFile repositoryFile;

        inhibitsSleep = true;

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
          # Add as much random delay as reasonably possible, to reduce the risk of multiple machines trying to access the repo simultaneously, or of backup runs and a check or prune run running at the same time.
          RandomizedDelaySec = "2d";
        };

        # backupPrepareCommand = ''${hc-sh} "${hostname}-restic-prune/start?create=1"'';
        # backupCleanupCommand = ''${hc-sh} "${hostname}-restic-prune/$EXIT_CODE"'';

      };

      # Run a thorough check
      persist-check = {
        inherit environmentFile passwordFile repositoryFile;

        inhibitsSleep = true;

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
          # Add as much random delay as reasonably possible, to reduce the risk of multiple machines trying to access the repo simultaneously, or of backup runs and a check or prune run running at the same time.
          RandomizedDelaySec = "3d";
        };
        # backupPrepareCommand = ''${hc-sh} "${hostname}-restic-check/start?create=1"'';
        # backupCleanupCommand = ''${hc-sh} "${hostname}-restic-check/$EXIT_CODE"'';
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
