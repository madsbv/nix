{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.local.yubikey;
in {
  options = {
    local.yubikey.enable = lib.mkEnableOption "Enable Yubikey programs and services";
    local.ssh-clients.users = lib.mkOption {
      description = "List of users for which to deploy age-encrypted private SSH keys.";
      default = [ ];
    };
  };
  config = lib.mkIf cfg.enable {
    services.yubikey-agent.enable = true;
    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubioath-flutter
    ];
  };
}
