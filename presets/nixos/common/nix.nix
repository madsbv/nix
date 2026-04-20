{
  config,
  lib,
  pkgs,
  ...
}:

{
  nix = {
    daemonCPUSchedPolicy = "idle";
    daemonIOSchedClass = "idle";
    settings = {
      auto-allocate-uids = lib.mkDefault true;
      system-features = [ "uid-range" ];
      experimental-features = [
        "auto-allocate-uids"
        "cgroups"
      ];
    };
  };
}
