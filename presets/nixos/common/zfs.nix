{
  config,
  lib,
  ...
}:

{

  services.zfs = lib.mkIf config.boot.zfs.enabled {
    autoSnapshot.enable = true;
    # autoSnapshot by default keeps hourly snapshots for whole day, daily snapshots for a week, and so on, up to monthly snapshots for a year. That might be a bit much for disk storage reasons.
    autoSnapshot.monthly = 2;
    autoScrub.enable = true;
    # zfs enables periodic TRIM by default
  };
}
