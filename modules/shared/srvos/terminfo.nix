{ pkgs, ... }:
{

  # various terminfo packages
  environment.systemPackages = [
    pkgs.wezterm.terminfo
    pkgs.termite.terminfo
    pkgs.kitty.terminfo
  ];
}
