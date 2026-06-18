{
  flake-root,
  pkgs,
  lib,
  ...
}:
{
  imports = [ ../../../presets/home-manager/client ];

  xdg.configFile = {
    "svim".source = flake-root + "/config/svim";
    "sketchybar".source = flake-root + "/config/sketchybar";
    "karabiner".source = flake-root + "/config/karabiner";
  };

  home = {
    packages = with pkgs; [
      dockutil
      pinentry_mac
      pngpaste
      # LLM testing
      # llm.withPlugins
      # ([ "llm-gpt4all" ])
      # ollama
    ];
  };
  programs = {
    kitty.darwinLaunchOptions = [ "--single-instance" ];
    # Awaiting GTK3 fix: https://nixpk.gs/pr-tracker.html?pr=449689
    librewolf.enable = lib.mkForce false;
  };
}
