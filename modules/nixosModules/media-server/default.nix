{
  lib,
  config,
  ...
}:
let
  cfg = config.local.server.media;
in
{
  options.local.server.media.enable = lib.mkEnableOption "media server";
  config = lib.mkIf cfg.enable {
    imports = [
      ./jellyfin
      ./transmission
      ./ripping
    ];
  };
}
