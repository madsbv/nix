{ pkgs }:

with pkgs; [
  # General packages for development and system management
  bash-completion
  bat
  eza
  btop
  coreutils
  killall
  openssh
  sqlite
  perl
  wget
  zip
  fd

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
  # Function provided by nixpkgs. Required to build aspell together with its dictionaries, otherwise they will be isolated from each other in the nix store.
  # en-computers and en-science are two special dictionaries (and the only ones provided) for computer and science jargon.
  (aspellWithDicts (dicts: with dicts; [ en en-computers en-science de da ]))
  hunspell
  languagetool
  enchant
  bibutils
  stylelint
  texlab
  # wordnet # Build broken
  texliveFull

  # Documents
  djvulibre
  poppler

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
  # pipenv

  # JavaScript
  nodePackages.nodejs
  # For yaml formatting, among other things
  nodePackages.prettier

  # Misc language servers
  yaml-language-server
  sqls
  lua-language-server

]
