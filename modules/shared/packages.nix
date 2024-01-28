{ pkgs }:

with pkgs; [
  # General packages for development and system management
  alacritty
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
  fd
  gh

  # Encryption and security tools
  age
  age-plugin-yubikey
  gnupg
  libfido2
  pinentry
  bitwarden-cli

  # Backups
  restic
  autorestic

  # Media-related packages
  emacs-all-the-icons-fonts
  nerdfonts
  dejavu_fonts
  ffmpeg
  font-awesome
  hack-font
  noto-fonts
  noto-fonts-emoji
  meslo-lgs-nf
  imagemagick
  graphviz
  portaudio

  # Communication tools
  zoom-us
  discord
  # signal-desktop # nix pkg only supported on linux

  # Text and terminal utilities
  htop
  iftop
  jq
  ripgrep
  tree
  tmux
  unrar
  unzip
  zsh-powerlevel10k
  multimarkdown
  pandoc

  # Writing
  aspell
  aspellDicts.en
  hunspell
  languagetool
  enchant
  bibutils
  stylelint
  texlab
  # wordnet # Build broken
  # TODO: Enable when everything else works
  # texliveFull

  # Documents
  djvulibre
  # djview # Broken on darwin
  poppler
  # calibre # Currently broken on darwin

  # Email
  isync
  mu

  # nix
  nixfmt
  nil

  # rust
  rustup

  # Shell scripts
  nodePackages.bash-language-server
  shellcheck
  shfmt

  # Python
  isort
  pipenv

  # Misc language servers
  yaml-language-server
  sqls
  lua-language-server

  # TODO: Figure out which of the old homebrew packages we actually need, and which should be installed shared vs on Darwin specifically, and which can be installed through nix vs homebrew.
]

#
