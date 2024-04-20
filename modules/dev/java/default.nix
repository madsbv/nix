{ config, lib, ... }:

{
  home-manager.sharedModules = lib.mkIf config.local.hm.enable [ { programs.java.enable = true; } ];
}
