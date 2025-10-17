{
  pkgs,
  ...
}:

let
  myRPackages = with pkgs.rPackages; [
    ggplot2
    dplyr
    xts
  ];
  RWithPackages = pkgs.rWrapper.override { packages = myRPackages; };
  RStudioWithPackages = pkgs.rstudioWrapper.override { packages = myRPackages; };
in
{
  environment = {
    systemPackages = with pkgs; [
      RWithPackages
      RStudioWithPackages
    ];
  };

}
