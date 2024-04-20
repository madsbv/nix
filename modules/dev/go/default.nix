{ pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    go
    gopls
    gomodifytags
    gotests
    gore
    gotools
  ];
}
