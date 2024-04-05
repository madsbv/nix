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
  config.launchd.daemons.auotrestic.serviceConfig =
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
}
