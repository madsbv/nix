_:

[
  # TODO: See which of these can be moved to native nix management, ideally shared.
  # Development Tools

  # Fonts
  "sf-symbols"

  # Math
  "sage" # There's a sage package in nixpkgs, but it's linux specific
  # "mactex"

  # Gaming
  "steam" # Seems like nixos has a programs.steam, but nix-darwin does not.

  # Documents
  # "calibre"
  # "djview"

  # Communication Tools
  # "discord"
  # "zoom"

  # Entertainment Tools
  "vlc" # The nixpkgs version is linux-specific

  # System/Productivity Tools
  "raycast"
  "unnaturalscrollwheels"

  # Browsers
  # The nixpkgs versions seem linux-specific
  "firefox"
  "vivaldi"

  # Communication
  "signal"

  # Docs
  "calibre"
  "djview4"

  # System stuff
  # TODO: Do I have to do something to activate noclamshell?
  # More importantly, can I do this natively with nix-darwin?
  "pirj/noclamshell/noclamshell "
  "felixkratz/formulae/border"
  "felixkratz/formulae/svim"
]
# Built in nix-darwin services:
# sketchybar
# skhd
# yabai
# karabiner-elements

# brew "railwaycat/emacsmacport/emacs-mac", args: ["with-imagemagick", "with-native-compilation", "with-no-title-bars", "with-starter", "with-unlimited-select", "with-xwidgets"]
