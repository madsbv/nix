{
  inputs,
  flake-root,
  hostname,
  color-scheme,
  ...
}:

{
  local.homeManager.enable = true;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "home-manager-backup";
    extraSpecialArgs = {
      inherit
        hostname
        flake-root
        inputs
        color-scheme
        ;
    };
  };
}
