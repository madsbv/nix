{ pkgs, ... }:
{

  # various terminfo packages
  environment.systemPackages = [
    pkgs.wezterm.terminfo
    pkgs.kitty.terminfo
  ];
}
