{
  config,
  lib,
  flake-root,
  pkgs,
  hostname,
  ...
}:

# TODO: https://wiki.nixos.org/wiki/Restic#Security_Wrapper

let
  cfg = config.local.restic;
  environmentFile = config.age.secrets.restic-env.path;
  passwordFile = config.age.secrets.restic-password.path;
  repositoryFile = config.age.secrets.restic-repo.path;

  niceRestic = pkgs.restic.overrideAttrs (old: {
    installPhase = (old.installPhase or "") + ''
      wrapProgram $out/bin/restic --set GOMAXPROCS 8
    '';
  });
in
{
  options.local.restic = {
    enable = lib.mkEnableOption "Enable automatic Restic backups";
    paths = lib.mkOption { default = [ "/nix/persist" ]; };
    exclude = lib.mkOption { default = [ ]; };
    persistPath = lib.mkOption { default = "/nix/persist"; };
    persistCache = lib.mkEnableOption "Add the Restic cache directory to the set of directories persisted to cfg.persistPath.";
  };

  config =
    let
      exclude = cfg.exclude ++ [ ".cache" ];
      # Storage optimization
      resticOpts = [
        # For storage cost and especially transfer cost reasons, better compression might have some benefits
        "--compression=max"
        # We have plenty of memory to work with on all machines, and upload should be fast enough. Default pack size is 16MiB
        "--pack-size=64"
        "--cleanup-cache"
        "--retry-lock=2h"
      ];

      forgetSchedule = [
        "--keep-last 14"
        "--keep-daily 14"
        "--keep-weekly 10"
        "--keep-monthly 12"
        "--keep-yearly 10"
      ];

      hcsh = lib.getExe (
        pkgs.writeShellApplication {
          name = "restic-backup-healthchecks";
          runtimeInputs = [
            pkgs.curl
            pkgs.jq
            config.age.secrets.healthchecks.path
          ];
          text = ''
            # shellcheck source=/dev/null
            source ${config.age.secrets.healthchecks.path}

            SLUG=$1
            CMD=$2
            DATA=$3

            update="true"

            resp=$(curl -s -o /dev/null -w "%{http_code}" -m 10 --retry 5 -X POST -H "Content-Type: text/plain" "https://hc-ping.com/$PING_KEY/$SLUG/$CMD?create=1")
            if { [ "$update" = "true" ] && [ "$resp" = "200" ] ;} || [ "$resp" = "201" ]; then
                # Get UUID for check and update configuration
                # In this case the slug should exist and be unique. It exists because of the successful post above,
                # and is unique because otherwise healthchecks.io would return a "409 ambiguous slug", not a 201.
                UUID=$(curl -s "https://healthchecks.io/api/v3/checks/?slug=$SLUG" --header "X-Api-Key: $API_KEY" | jq --raw-output '.checks[0].uuid')
                curl -m 10 --retry 5 -X POST "https://healthchecks.io/api/v3/checks/$UUID" --header "X-Api-Key: $API_KEY" --data "$DATA"
            fi
          '';
        }
      );

      # daysToSecs = days: builtins.toString (days * 24 * 60 * 60);
      daysToSecs = days: days * 24 * 60 * 60;
      # See https://healthchecks.io/docs/api/ "Update an Existing Check" for parameters
      healthchecksParams = args: {
        name = "${hostname} ${args.name}";
        slug = "${hostname}-${args.name}";
        tags = "${hostname} ${args.tags}";
        schedule = args.schedule or "weekly";
        grace = args.grace or (daysToSecs 10);
        tz = args.tz or config.time.timeZone or "Europe/Copenhagen";
      };
      # See Endpoints for possible cmd values details: https://healthchecks.io/docs/http_api/
      # Current options are: start, fail, log, or a numerical process exit status.
      # Empty cmd indicates success, avoid using this.
      #
      # args are currently only used when the check is first initialized, though that may change in the future.
      #
      # args should be an attrSet with at minimum a name attr, but probably also schedule and tags.
      healthchecksCmd =
        cmd: oargs:
        let
          args = healthchecksParams oargs;
        in
        ''${hcsh} "${args.slug}" "${cmd}" ''\'${builtins.toJSON args}''\''';
      hcBackupCommands = args: {
        backupPrepareCommand = healthchecksCmd "start" args;
        backupCleanupCommand = healthchecksCmd "$EXIT_STATUS" args;
      };
    in
    lib.mkIf cfg.enable {

      services.restic.backups = {

        # Job to do regular backups, but no cleanup or checking since those are expensive to run often.
        persist =
          let
            schedule = "daily";
            hcArgs = {
              inherit schedule;
              name = "backup-persist";
              tags = "backup";
              grace = daysToSecs 2;
            };
            hcCommands = hcBackupCommands hcArgs;
          in
          {
            inherit (hcCommands) backupPrepareCommand backupCleanupCommand;
            inherit (cfg) paths;
            inherit exclude;
            inherit environmentFile passwordFile repositoryFile;

            package = niceRestic;

            initialize = true;

            # Creates restic-persist in path
            createWrapper = true;

            extraBackupArgs = [
              # Don't backup directories containing a `CACHEDIR.TAG` file (like restic's own cache)
              "--exclude-caches=true"
              # Increase the number of files read in parallel from the default of 2 (especially useful on fast NVMe storage)
              "--read-concurrency=8"
              # We're running the backup headless, so there's no reason to show progress estimation
              "--no-scan"
            ]
            ++ resticOpts;

            # Set the default explicitly to avoid accidental pruning
            # This disables `forget --prune` from running after backups.
            pruneOpts = [ ];
            runCheck = false;

            timerConfig = {
              OnCalendar = schedule;
              Persistent = true;
              # Add as much random delay as reasonably possible, to reduce the risk of multiple machines trying to access the repo simultaneously, or of backup runs and a check or prune run running at the same time.
              RandomizedDelaySec = "20h";
            };
          };

        # Occasionally prune and optimize storage and run cached check.
        persist-prune =
          let
            schedule = "Mon";
            hcArgs = {
              inherit schedule;
              name = "prune-persist";
              tags = "prune";
              grace = daysToSecs 3;
            };
            hcCommands = hcBackupCommands hcArgs;
          in
          {
            inherit (hcCommands) backupPrepareCommand backupCleanupCommand;
            inherit environmentFile passwordFile repositoryFile;

            package = niceRestic;
            # inhibitsSleep = true;

            # Explicitly disable taking backups
            paths = null;
            dynamicFilesFrom = null;

            # Quick check with cache. persist-check job does in-depth checking.
            checkOpts = [ "--with-cache" ] ++ resticOpts;

            pruneOpts =
              forgetSchedule
              ++ [
                # Only compresses completely uncompressed data, so this doesn't recompress auto-compressed data using max compression.
                "--repack-uncompressed"
                # Only do most immpactful repacking
                "--max-repack-size='10G'"
                # 251113: --repack-small would repack ~300GB without saving any space (literally 0B).
                # "--repack-small"
              ]
              ++ resticOpts;

            timerConfig = {
              # Run every Monday
              OnCalendar = schedule;
              Persistent = true;
              # Add as much random delay as reasonably possible, to reduce the risk of multiple machines trying to access the repo simultaneously, or of backup runs and a check or prune run running at the same time.
              RandomizedDelaySec = "2d";
            };

          };

        # Run a thorough check
        persist-check =
          let
            schedule = "Wed";
            hcArgs = {
              inherit schedule;
              name = "check-persist";
              tags = "check";
              grace = daysToSecs 4;
            };
            hcCommands = hcBackupCommands hcArgs;
          in
          {
            inherit (hcCommands) backupPrepareCommand backupCleanupCommand;
            inherit environmentFile passwordFile repositoryFile;

            package = niceRestic;

            # Explicitly disable taking backups
            paths = null;
            dynamicFilesFrom = null;

            # Don't use local cache to ensure that we check repo data, and additionally download 1G of random backup data and verify its integrity.
            checkOpts = [ ''--read-data-subset="1G"'' ] ++ resticOpts;

            # No pruning here, only in persist-prune.
            pruneOpts = [ ];

            timerConfig = {
              OnCalendar = schedule;
              Persistent = true;
              # Add as much random delay as reasonably possible, to reduce the risk of multiple machines trying to access the repo simultaneously, or of backup runs and a check or prune run running at the same time.
              RandomizedDelaySec = "3d";
            };
          };
      };

      age.secrets = lib.mkIf cfg.enable {
        restic-env.rekeyFile = flake-root + "/secrets/restic/env.age";
        restic-repo.rekeyFile = flake-root + "/secrets/restic/repo.age";
        restic-password.rekeyFile = flake-root + "/secrets/restic/password.age";
        healthchecks = {
          rekeyFile = flake-root + "/secrets/other/healthchecks.sh.age";
          name = "healthchecks";
          mode = "u=r"; # 0400
        };
      };

      environment.persistence.${cfg.persistPath}.directories = lib.mkIf cfg.persistCache [
        # Restic basically needs its cache to be able to run in a reasonable amount of time
        "/var/cache/restic-backups-persist"
      ];
    };
}
