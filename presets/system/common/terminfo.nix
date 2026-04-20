{ pkgs, ... }:
{

  # various terminfo packages
  environment.systemPackages = [
    pkgs.wezterm.terminfo
    pkgs.kitty.terminfo
    pkgs.alacritty.terminfo
    pkgs.ncurses
  ]
  ++ (if pkgs.stdenv.isDarwin then [ pkgs.ghostty-bin.terminfo ] else [ pkgs.ghostty.terminfo ]);
}
