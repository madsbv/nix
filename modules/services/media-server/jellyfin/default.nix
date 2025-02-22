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
  ];

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/jellyfin"
    ];
  };
}
