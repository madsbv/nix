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
  gdu

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
  ripgrep-all
  zoxide
  fzf
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
  texliveFull

  # Documents
  djvulibre
  poppler

  # nix
  nixfmt
  nil

  # rust
  # cargo-audit # Dependency libgit fails to compil
  cargo-flamegraph
  # cargo-instruments # Not in nixpkgs
  cargo-generate
  cargo-diet
  cargo-msrv

  # Shell scripts
  nodePackages.bash-language-server
  shellcheck
  shfmt

  # Python
  isort
  black
  python311Packages.pyflakes
  python311Packages.pytest
  nodePackages.pyright

  # JavaScript
  nodePackages.nodejs
  nodePackages.typescript-language-server
  nodePackages.js-beautify
  # For yaml formatting, among other things
  nodePackages.prettier
  nodePackages.eslint

  # Golang
  gopls
  gomodifytags
  gotests
  gore
  gotools

  # Misc language servers
  yaml-language-server
  sqls
  lua-language-server
  vscode-langservers-extracted

  # Misc Doomemacs dependencies
  coreutils-prefixed # Mostly for GNU ls
  cmake
  fontconfig
]
