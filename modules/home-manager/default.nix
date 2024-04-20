{
  user,
  hostname,
  osConfig,
  pkgs,
  ...
}:

# Home manager configuration for graphical client machines.

let
  # Really just for git
  name = "Mads Bach Villadsen";
  email = "mvilladsen@pm.me";
in
{
  imports = [ ./email.nix ];

  home = {
    packages = pkgs.callPackage ./packages.nix { };
  };

  programs = {
    ssh = {
      enable = true;
      package = pkgs.openssh;
      matchBlocks = {
        "github.com" = {
          hostname = "github.com";
          identitiesOnly = true;
        };
      };
      extraOptionOverrides.IdentityFile = osConfig.age.secrets."id.${hostname}.${user}".path;
    };
    gh = {
      enable = true;
      settings.editor = "vim";
    };
    git = {
      userName = name;
      userEmail = email;
    };
  };
}
