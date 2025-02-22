{
  pkgs,
  ...
}:

{

  services = {
    # Default port 9091
    transmission = {
      enable = true;
      package = pkgs.transmission_4;
      settings = {
        watch-dir-enabled = true;
        rpc-bind-address = "0.0.0.0";
        # NOTE: There is a script-torrent-done setting to run a script on download completion. Could be used to automate transcoding and organization of files.
      };
    };
    # See https://www.reddit.com/r/NixOS/comments/12ibbl9/protonvpn_nixos_setup/ for potential protonvpn nixos integration options
  };

  environment.persistence."/nix/persist" = {
    directories = [
      "/var/lib/transmission"
    ];
  };
}
