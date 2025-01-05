{
  mod,
  user,
  config,
  lib,
  osConfig,
  hostname,
  pkgs,
  flake-root,
  flake-inputs,
  base16-kitty,
  bootdev,
  ...
}:

# Home manager configuration for graphical client machines.

let
  # Really just for git
  name = "Mads Bach Villadsen";
  email = "mvilladsen@pm.me";
in
{
  imports = [
    ./email.nix
    (mod "home-manager/common/common")
  ];

  home = {
    packages = pkgs.callPackage ./packages.nix { inherit (flake-inputs) nox; };
  };

  local = {
    email = {
      enable = true;
      maildir = "${config.xdg.dataHome}/Mail";
      muhome = "${config.xdg.cacheHome}/mu";
      muAddressArgs = osConfig.age.secrets.mu-init-addresses.path;
      pmbridge-password = osConfig.age.secrets.pmbridge-password.path;
    };
  };

  home = {
    sessionPath = [ "$HOME/go/bin" ];
    sessionVariables = {
      TERMINAL = "kitty";
    };
  };

  programs = {

    go = {
      enable = true;
      goPath = "go";
      packages = {
        "github.com/bootdotdev/bootdev" = bootdev;
      };
    };

    kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      # TODO: Either do settings natively in nix, or figure out how to just manage this config file as xdg config?
      extraConfig =
        builtins.readFile (flake-root + "/config/kitty/kitty.conf")
        + builtins.readFile (config.scheme base16-kitty);
    };
    wezterm = {
      enable = true;
      enableZshIntegration = true;
    };

    # mbv: Let's just use this for now
    alacritty = {
      enable = true;
      settings = {
        cursor = {
          style = "Block";
        };

        window = {
          opacity = 1.0;
          padding = {
            x = 24;
            y = 24;
          };
        };

        font = {
          normal = {
            family = "MesloLGS NF";
            style = "Regular";
          };
          size = lib.mkMerge [
            (lib.mkIf pkgs.stdenv.hostPlatform.isLinux 10)
            (lib.mkIf pkgs.stdenv.hostPlatform.isDarwin 14)
          ];
        };

        # Base16 colors
        colors =
          with config.scheme.withHashtag;
          let
            default = {
              black = base00;
              white = base07;
              inherit
                red
                green
                yellow
                blue
                cyan
                magenta
                ;
            };
          in
          {
            primary = {
              background = base00;
              foreground = base07;
            };
            cursor = {
              text = base02;
              cursor = base07;
            };
            normal = default;
            bright = default;
            dim = default;
          };
      };
    };
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
