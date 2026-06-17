{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    nixfmt
    nil
    deadnix
    statix
  ];
}
