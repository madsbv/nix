{
  config,
  ...
}:

{
  services.dropbox = {
    # NOTE: For the Dropbox daemon to work under Nix, the directories `~/.dropbox ~/.dropbox-dist` have to be symlinked into the corresponding directories in `~/.dropbox-hm`, which contains all the nix linking/environment stuff required.
    # The home-manager service definition does do this, but only if the paths don't already exist. This means that if dropbox is ever run while the links are not in place, they will clobber those paths with actual directories, and the service will then not fix it.
    # It might be worth just deleting those paths on every activation and have the service relink.
    enable = true;
    path = "${config.home.homeDirectory}/Dropbox";
  };
}
