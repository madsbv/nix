{
  config,
  lib,
  pkgs,
  osConfig,
  user,
  hostname,
  ...
}:
let
  cfg = config.local.ssh;
in {
  options.local.ssh = {
    enable = lib.mkEnableOption "SSH client";
  };

  config = lib.mkIf cfg.enable {
    programs.ssh = {
      enable = true;
      package = pkgs.openssh;
      enableDefaultConfig = false;
      settings = {
        "*" = {
          ServerAliveInterval = 0;
          ServerAliveCountMax = 3;
          HashKnownHosts = false;
          UserKnownHostsFile = "~/.ssh/known_hosts";
        };
        "github.com" = {
          HostName = "github.com";
          IdentitiesOnly = true;
        };
      };
      extraOptionOverrides.IdentityFile = osConfig.age.secrets."id.${hostname}.${user}".path;
    };
  };
}
