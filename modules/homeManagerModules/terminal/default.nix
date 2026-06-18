{
  config,
  lib,
  pkgs,
  inputs,
  flake-root,
  ...
}:
let
  cfg = config.local.terminal;
in {
  options.local.terminal = {
    enable = lib.mkEnableOption "Terminal emulators";
    kitty.enable = lib.mkEnableOption "kitty terminal" // { default = true; };
    wezterm.enable = lib.mkEnableOption "wezterm terminal" // { default = true; };
    alacritty.enable = lib.mkEnableOption "alacritty terminal" // { default = true; };
  };

  config = lib.mkIf cfg.enable {
    programs = {
      kitty = lib.mkIf cfg.kitty.enable {
        enable = true;
        shellIntegration.enableZshIntegration = true;
        extraConfig =
          builtins.readFile (flake-root + "/config/kitty/kitty.conf")
          + builtins.readFile (config.scheme inputs.base16-kitty);
      };

      wezterm = lib.mkIf cfg.wezterm.enable {
        enable = true;
        enableZshIntegration = true;
      };

      alacritty = lib.mkIf cfg.alacritty.enable {
        enable = true;
        settings = {
          cursor.style = "Block";
          window = {
            opacity = 1.0;
            padding = { x = 24; y = 24; };
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
          colors = with config.scheme.withHashtag; let
            default = {
              black = base00;
              white = base07;
              inherit red green yellow blue cyan magenta;
            };
          in {
            primary = { background = base00; foreground = base07; };
            cursor = { text = base02; cursor = base07; };
            normal = default;
            bright = default;
            dim = default;
          };
        };
      };
    };
  };
}
