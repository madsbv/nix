{
  lib,
  config,
  ...
}:
let
  cfg = config.local.server.media;
in
{
  imports = [
    ./jellyfin
    ./transmission
    ./ripping
  ];
  options.local.server.media.enable = lib.mkEnableOption "media server";
}
