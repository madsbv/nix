{
  pkgs,
  ...
}:

{
  environment = {
    systemPackages = with pkgs; [
      fortls
      gfortran
      fpm
      fprettify
    ];
  };

}
