{
  flake-root,
  inputs,
  pkgs,
  config,
  lib,
  osConfig,
  ...
}:
{
  imports = [
    (flake-root + "/modules/home-manager")
    ./email.nix
  ];

  local.doomemacs.enable = true;

  local.email = {
    enable = true;
    maildir = "${config.xdg.dataHome}/Mail";
    muhome = "${config.xdg.cacheHome}/mu";
    muAddressArgs = osConfig.age.secrets.mu-init-addresses.path;
    pmbridge-password = osConfig.age.secrets.pmbridge-password.path;
  };

  xdg.configFile = {
    "svim".source = flake-root + "/config/svim";
    "sketchybar".source = flake-root + "/config/sketchybar";
    "karabiner".source = flake-root + "/config/karabiner";
  };

  home = {
    packages = pkgs.callPackage ./packages.nix { };

    shellAliases = {
      wget = "wget --hsts-file=${config.xdg.cacheHome}/.wget-hsts";
      ec = "emacsclient -c -n -a nvim";
      gj = "just ${config.xdg.configHome}/nix/";

      grep = "grep -i --color=always";
      ls = "ls -A -B -F -G -h";
      # Supposedly the space at the end of these aliases should make these commands
      # work with other aliases as input.
      watch = "watch -cd ";
      sudo = "sudo ";
    };
  };

  # NOTE: Trying to use `(pkgs.emacsPackagesFor my-emacs-mac).emacsWithPackages` and an override at the same time breaks things via weird nix double wrapping issues, so use extraPackages instead.
  # TODO: Define a launchd service for emacs daemon? Could be useful, could break tinkering. If yes, see ryan4yin-nix-config for an example.
  programs = {
    zsh.envExtra = ''
      export RESTIC_CACHE_DIR="/Users/mvilladsen/Library/Caches/restic"
      export PATH="$XDG_CONFIG_HOME/emacs/bin:$HOME/.local/bin:$HOME/.cargo/bin''${PATH+:$PATH}";
    '';

    neovim.plugins = [
      (pkgs.vimPlugins.base16-vim.overrideAttrs (
        _old:
        let
          schemeFile = config.scheme inputs.base16-vim;
        in
        {
          patchPhase = "cp ${schemeFile} colors/base16-scheme.vim";
        }
      ))
    ];

    kitty = {
      enable = true;
      shellIntegration.enableZshIntegration = true;
      # TODO: Either do settings natively in nix, or figure out how to just manage this config file as xdg config?
      extraConfig =
        builtins.readFile (flake-root + "/config/kitty/kitty.conf")
        + builtins.readFile (config.scheme inputs.base16-kitty);
      darwinLaunchOptions = [ "--single-instance" ];
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
