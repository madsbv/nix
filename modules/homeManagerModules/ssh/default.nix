{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:

let
  cfg = config.local.ssh;
in
{
  options.local.ssh = {
    enable = lib.mkEnableOption "SSH client";
    identityFile = lib.mkOption {
      type = lib.types.nullOr lib.types.path;
      default =
        osConfig.age.secrets.id.${osConfig.local.common.hostname}.${config.home.username}.path or null;
      description = "Path to SSH identity key. Defaults to agenix-provisioned key if available.";
    };
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
      extraOptionOverrides = lib.mkIf (cfg.identityFile != null) {
        IdentityFile = cfg.identityFile;
      };
    };
  };
}
