{
  flake-root,
  base16-kitty,
  bootdev,
  pkgs,
  config,
  lib,
  osConfig,
  mod,
  ...
}:
{
  imports = [ (mod "home-manager") ];

  local = {
    doomemacs.enable = true;
    email = {
      enable = true;
      maildir = "${config.xdg.dataHome}/Mail";
      muhome = "${config.xdg.cacheHome}/mu";
      muAddressArgs = osConfig.age.secrets.mu-init-addresses.path;
      pmbridge-password = osConfig.age.secrets.pmbridge-password.path;
    };
  };

  xdg.configFile = {
    "svim".source = flake-root + "/config/svim";
    "sketchybar".source = flake-root + "/config/sketchybar";
    "karabiner".source = flake-root + "/config/karabiner";
  };

  home = {
    packages = pkgs.callPackage ./packages.nix { };
    sessionPath = [ "$HOME/go/bin" ];
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
      darwinLaunchOptions = [ "--single-instance" ];
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
  };
}
