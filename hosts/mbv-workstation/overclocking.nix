{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    stress
    stress-ng
    stressapptest
    s-tui
    firestarter
    furmark
    mprime
    hpl
  ];
}
