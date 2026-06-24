{
  config,
  lib,
  pkgs,
  flake-root,
  hostname,
  ...
}:
let
  inherit (lib) types;
  cfg = config.local.users;
in
{
  options.local.users = {
    enable = lib.mkEnableOption "user management abstraction";
    primaryUser = lib.mkOption {
      type = types.str;
      default = "mvilladsen";
      description = "Username of the primary user for the system.";
    };
    users = lib.mkOption {
      type = types.attrsOf (
        types.submodule {
          options = {
            username = lib.mkOption { type = types.str; };
            fullName = lib.mkOption { type = types.str; };
            email = lib.mkOption {
              type = types.nullOr types.str;
              default = null;
            };
            extraGroups = lib.mkOption {
              type = types.listOf types.str;
              default = [ ];
            };
            isAuthorized = lib.mkOption {
              type = types.bool;
              default = false;
              description = "Whether this user gets SSH authorized_keys access.";
            };
            homeManager = lib.mkOption {
              type = types.listOf types.raw;
              default = [ ];
              description = "Home-manager module imports for this user.";
            };
          };
        }
      );
      default = {
        mvilladsen = {
          username = "mvilladsen";
          fullName = "Mads Bach Villadsen";
          email = "mvilladsen@pm.me";
          isAuthorized = true;
        };
      };
      description = "User definitions with identity and home-manager config.";
    };
  };

  config = lib.mkIf cfg.enable {
    home-manager = lib.mkIf config.local.homeManager.enable {
      users = lib.mapAttrs' (
        _: u:
        lib.nameValuePair "${u.username}" {
          imports = u.homeManager;
          home = {
            username = u.username;
            homeDirectory = lib.mkDefault (
              if pkgs.stdenv.isDarwin then "/Users/${u.username}" else "/home/${u.username}"
            );
            stateVersion = lib.mkDefault "23.11";
          };
        }
      ) cfg.users;
      sharedModules = [
        ({ osConfig, config, ... }: {
          imports = [ ../../homeManagerModules/user-profile ];
          config.local.userProfile = lib.mkIf (osConfig.local.users.users ? ${config.home.username}) {
            username = config.home.username;
            fullName = osConfig.local.users.users.${config.home.username}.fullName;
            email = osConfig.local.users.users.${config.home.username}.email;
          };
        })
      ];
    };
    age = lib.mkIf (config.local.agenix.enable or false) (
      lib.mapAttrs' (
        _: u:
        lib.nameValuePair "secrets.id.${config.local.common.hostname or hostname}.${u.username}" {
          rekeyFile =
            flake-root
            + "/secrets/ssh/id_ed25519.${config.local.common.hostname or hostname}.${u.username}.age";
          owner = u.username;
        }
      ) cfg.users
    );
  };
}
