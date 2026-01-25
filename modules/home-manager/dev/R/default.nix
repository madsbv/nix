{
  pkgs,
  lib,
  config,
  ...
}:

let
  cfg = config.local.dev.r;
  myRPackages = with pkgs.rPackages; [
    ggplot2
    dplyr
    tidyverse
    tidyr
    stringr
    lubridate
    tidymodels
    magrittr
    snakecase
    readxl
    readODS
    swirl
    xts
  ];
  RWithPackages = pkgs.rWrapper.override { packages = myRPackages; };
  RStudio = pkgs.rstudio.override { hunspellDicts = { }; };
  RStudioWithPackages = pkgs.rstudioWrapper.override {
    packages = myRPackages;
    rstudio = RStudio;
  };
in
{
  options.local.dev.r.enable = lib.mkEnableOption "R";

  config = lib.mkIf cfg.enable {
    home.packages = [
      RWithPackages
      RStudioWithPackages
    ];
  };
}
