{ config, lib, ... }:

let
  cfg = config.local.git;
in
{
  options.local.git = {
    enable = lib.mkEnableOption "Git user config" // {
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git.settings.user = {
      name = config.local.userProfile.fullName;
      email = config.local.userProfile.email;
    };
  };
}
