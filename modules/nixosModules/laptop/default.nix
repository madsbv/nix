{
  pkgs,
  ...
}:

{
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
}
