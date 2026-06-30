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
  options.local = {
    primaryUser = lib.mkOption {
      type = types.str;
      default = "mvilladsen";
      description = "Username of the primary user for the system.";
    };
    users = lib.mkOption {
      type = types.submodule {
        options = {
          enable = lib.mkEnableOption "user management abstraction";
        };
        freeformType = types.attrsOf (
          types.submodule (
            { name, ... }:
            {
              options = {
                username = lib.mkOption {
                  type = types.str;
                  default = name;
                };
                fullName = lib.mkOption {
                  type = types.str;
                  default = name;
                };
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
          )
        );
      };
      default = {
        enable = false;
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
      ) (builtins.removeAttrs cfg [ "enable" ]);
      sharedModules = [
        ({ osConfig, config, ... }: {
          imports = [ ../../homeManagerModules/user-profile ];
          config.local.userProfile =
            lib.mkIf
              (builtins.hasAttr config.home.username (builtins.removeAttrs osConfig.local.users [ "enable" ]))
              {
                username = config.home.username;
                fullName = osConfig.local.users.${config.home.username}.fullName;
                email = osConfig.local.users.${config.home.username}.email;
              };
        })
      ];
    };
    age.secrets = lib.mkIf (config.local.agenix.enable or false) (
      lib.mapAttrs' (
        _: u:
        lib.nameValuePair "id.${config.local.common.hostname or hostname}.${u.username}" {
          rekeyFile =
            flake-root
            + "/secrets/ssh/id_ed25519.${config.local.common.hostname or hostname}.${u.username}.age";
          owner = u.username;
        }
      ) (builtins.removeAttrs cfg [ "enable" ])
    );
  };
}
