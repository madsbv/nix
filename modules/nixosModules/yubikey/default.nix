{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.local.yubikey;
in
{
  options.local.yubikey.enable = lib.mkEnableOption "Enable Yubikey programs and services";
  config = lib.mkIf cfg.enable {

    services.yubikey-agent.enable = true;
    environment.systemPackages = with pkgs; [
      yubikey-manager
      yubioath-flutter
    ];
  };
}
