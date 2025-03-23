{ pkgs, ... }:

{
  environment = {
    variables = {
      CGO_ENABLED = "0";
    };
    systemPackages = with pkgs; [
      go
      gopls
      gomodifytags
      gotests
      gore
      gotools
    ];
  };
}
