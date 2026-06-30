{ config, lib, ... }:

let
  cfg = config.local.git;
  user = config.local.userProfile;
in
{
  options.local.git = {
    enable = lib.mkEnableOption "Git user config";
  };

  config = lib.mkIf cfg.enable {
    programs.git.settings.user = {
      name = lib.mkIf (user.fullName != null) user.fullName;
      email = lib.mkIf (user.email != null) user.email;
    };
  };
}
