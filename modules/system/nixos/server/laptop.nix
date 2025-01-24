{
  config,
  lib,
  pkgs,
  ...
}:

{
  # For laptop-based servers: Turn screen brightness on and off when lid is opened and closed.
  # From here, modified to user brightnessctl instead of writing directly to /sys files. https://github.com/waxlamp/nixos-config/blob/f8aecac4eb6e145f32d3c10f3842da18c217dd34/machines/kahless/configuration.nix#L171-L194

  services = {
    # Turn off logind handling of events; it can only do power off/suspend/hibernate/lock commands.
    logind = {
      lidSwitch = "ignore";
      extraConfig = ''
        HandlePowerKey=ignore
      '';
    };

    acpid = {
      enable = true;
      lidEventCommands = ''
        export PATH=$PATH:/run/current-system/sw/bin:${pkgs.brightnessctl/bin}:

        lid_state=$(cat /proc/acpi/button/lid/LID0/state | awk '{print $NF}')
        if [ $lid_state = "closed" ]; then
          # Set brightness to zero
          brightnessctl set 0%
        else
          # Reset the brightness
          brightnessctl set 50%
        fi
      '';

      powerEventCommands = ''
        systemctl suspend
      '';
    };
  };
}
