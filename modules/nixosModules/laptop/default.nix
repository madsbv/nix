{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.local.laptop;
in
{
  options.local.laptop = {
    enable = lib.mkEnableOption "laptop config";
  };
  config = lib.mkIf cfg.enable {
    # Set up screen brightness controls on laptops
    environment.systemPackages = [ pkgs.brightnessctl ];
    services.actkbd = {
      enable = true;
      bindings = [
        {
          keys = [ 224 ];
          events = [ "key" ];
          command = "${pkgs.brightnessctl}/bin/brightnessctl set -10%";
        }
        {
          keys = [ 225 ];
          events = [ "key" ];
          command = "${pkgs.brightnessctl}/bin/brightnessctl set +10%";
        }
      ];
    };
  };
}
