{
  pkgs,
  ...
}:

let
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
  environment = {
    systemPackages = with pkgs; [
      RWithPackages
      RStudioWithPackages
    ];
  };

}
