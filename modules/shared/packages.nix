{ pkgs }:

with pkgs; [
  # General packages for development and system management
  bash-completion
  bat
  eza
  btop
  coreutils
  inetutils
  killall
  openssh
  sqlite
  perl
  wget
  git
  zip
  zstd
  fd
  gdu

  # Encryption and security tools
  # agenix-rekey
  rage
  age-plugin-yubikey
  gnupg
  libfido2
  pinentry-emacs # 2024-03-18: The pinentry packages has been split up into multiple different packages exposing the different frontends. pinentry-emacs should expose the emacs, curses and tty frontends, but not the gtk and qt frontends which require linux.
  bitwarden-cli
  yubikey-agent
  yubikey-manager # Should be a CLI tool and shouldn't conflict with the homebrew yubico-yubikey-manager on Darwin

  # Backups
  restic
  autorestic

  # Networking
  tailscale

  # Media-related packages
  ffmpeg
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

  # Virtualization
  # qemu
  # libvirt
  # virt-manager

  # nix
  nixfmt
  nil

  # rust
  cargo-audit
  cargo-flamegraph
  cargo-generate
  cargo-diet
  cargo-msrv

  # Shell scripts
  nodePackages.bash-language-server
  shellcheck
  shfmt

  # Python
  python3
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
  go
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

  # Other programming tools
  hyperfine

  # Misc Doomemacs dependencies
  coreutils-prefixed # Mostly for GNU ls
  cmake
  fontconfig
]
