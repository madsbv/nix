{
  inputs,
  flake-root,
  hostname,
  ...
}:

{
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    backupFileExtension = "home-manager-backup";
    extraSpecialArgs = {
      inherit
        hostname
        flake-root
        inputs
        ;
    };
  };
}
