{
  config,
  lib,
  pkgs,
  hostname,
  ...
}:
let
  cfg = config.local.autorestic;
in
{
  options.local.autorestic = {
    enable = lib.mkOption { default = true; };
    ymlFile = lib.mkOption { description = "Path to the Autorestic yml configuration file."; };
  };
  config.launchd.daemons = {
    autorestic.serviceConfig =
      let
        label = "${hostname}.autorestic";
      in
      lib.mkIf cfg.enable {
        Label = label;
        ProgramArguments = [
          "${pkgs.autorestic}/bin/autorestic"
          "-c"
          "${cfg.ymlFile}"
          "--restic-bin"
          "${pkgs.restic}/bin/restic"
          "--ci"
          "-vv"
          "cron"
          "--lean"
        ];
        RunAtLoad = true;
        StandardErrorPath = "/tmp/${label}.log";
        StandardOutPath = "/tmp/${label}.log";
        # Autorestic handles job scheduling by itself, we just need to trigger it to do its check.
        # Runs every hour.
        StartCalendarInterval = [ { Minute = 0; } ];
      };
    # Convenience job to be able to do one-off operations on the backup repo with the correct environment set.
    # The default action is to diff two given revs of the backup; change hashes to explore state evolution, or change the action to do other checks.
    auotrestic-diff.serviceConfig =
      let
        label = "${hostname}.autorestic-diff";
      in
      lib.mkIf cfg.enable {
        Label = label;
        ProgramArguments = [
          "${pkgs.autorestic}/bin/autorestic"
          "-c"
          "${cfg.ymlFile}"
          "--restic-bin"
          "${pkgs.restic}/bin/restic"
          "--ci"
          "-vv"
          "exec"
          "-av"
          "--"
          "diff"
          "2d60380a"
          "d63b8032"
        ];
        RunAtLoad = true;
        StandardErrorPath = "/tmp/${label}.log";
        StandardOutPath = "/tmp/${label}.log";
      };
  };
}
