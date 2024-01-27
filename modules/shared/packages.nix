{ pkgs }:

with pkgs; [
  # General packages for development and system management
  alacritty
  aspell
  aspellDicts.en
  bash-completion
  bat
  btop
  coreutils
  killall
  kitty
  openssh
  sqlite
  perl
  wget
  zip

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  libfido2
  pinentry

  # Media-related packages
  emacs-all-the-icons-fonts
  nerdfonts
  dejavu_fonts
  ffmpeg
  fd
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-emoji
  meslo-lgs-nf
  imagemagick

  # Text and terminal utilities
  htop
  hunspell
  iftop
  jq
  ripgrep
  tree
  tmux
  unrar
  unzip
  zsh-powerlevel10k
  languagetool

  # nix
  nixfmt
  nil

  # rust
  rustup

  # TODO: Figure out which of the old homebrew packages we actually need, and which should be installed shared vs on Darwin specifically, and which can be installed through nix vs homebrew.

  ### Dev
  # brew "bash-language-server"
  # brew "yaml-language-server"
  # brew "sql-language-server"
  # brew "lua-language-server"
  # brew "shellcheck"
  # brew "shfmt"
  # brew "stylelint"
  # brew "texlab"
  ## Python
  # brew "isort"
  #
  # brew "bibutils"
  # brew "bitwarden-cli"
  #
  # brew "enchant"
  #
  # brew "djvulibre"
  # brew "djview4"
  # brew "poppler"
  #
  # brew "gnupg"
  #
  # brew "autorestic"
  #
  # brew "isync"
  # brew "mu"
]

# brew "pirj/noclamshell/noclamshell"
#
# brew "koekeishiya/formulae/skhd"
# brew "koekeishiya/formulae/yabai"
# brew "felixkratz/formulae/borders"
# brew "felixkratz/formulae/sketchybar"
# brew "felixkratz/formulae/svim"

# brew "graphviz"
# brew "markdown"
# brew "pandoc"
# brew "pinentry-mac"
# brew "pipenv"
# brew "pngpaste"
# brew "portaudio"
# brew "wordnet"
# brew "railwaycat/emacsmacport/emacs-mac", args: ["with-imagemagick", "with-native-compilation", "with-no-title-bars", "with-starter", "with-unlimited-select", "with-xwidgets"]
