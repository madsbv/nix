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
        rpc-whitelist-enabled = false;
        rpc-whitelist = "127.0.0.1,100.*.*.*";
        # From transmission docs (https://github.com/transmission/transmission/blob/main/docs/Editing-Configuration-Files.md):
        # The string starting with '{' indicates that this is an already-salted (whatever that means exactly) password.
        # Probably not safe to make public if it were an actual security measure, but it's layered with the whitelist.
        # rpc-password = "{2324d2649010be3adbde4f3b4aef125144cbd01d5l7l6xRl";
        # Require encrypted connections; can weaken to `1` "prefer encrypted" if 2 does not work.
        encryption = 2;
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
