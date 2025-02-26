{
  pkgs,
  lib,
  config,
  ...
}:

{
  # Import all directories in this folder
  imports =
    with builtins;
    filter (p: readFileType p == "directory") (map (p: ./. + "/${p}") (attrNames (readDir ./.)));

  environment.systemPackages = with pkgs; [
    tree-sitter
    # Good to just have generally available
    gcc
    clang
    llvm
  ];

  home-manager.sharedModules = lib.mkIf config.local.hm.enable [
    (
      { config, ... }:
      {
        programs.awscli = {
          enable = true;
          settings = {
            "default" = {
              region = "us-east-2";
            };
          };
          # TODO: Figure out how to add credentials
        };
      }
    )
  ];
}
