{
  pkgs,
  ...
}:

{
  services = {
    # Default port 8096
    jellyfin.enable = true;
  };

  environment.systemPackages = with pkgs; [
    jellyfin
    jellyfin-web
    jellyfin-ffmpeg
    jellyfin-media-player
  ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/jellyfin"
      "/var/lib/media"
    ];
  };
}
