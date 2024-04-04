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
  just

  # Encryption and security tools
  # agenix-rekey
  rage
  age-plugin-yubikey
  gnupg
  libfido2
  pinentry-emacs # 2024-03-18: The pinentry packages has been split up into multiple different packages exposing the different frontends. pinentry-emacs should expose the emacs, curses and tty frontends, but not the gtk and qt frontends which require linux.
  yubikey-agent
  yubikey-manager # Should be a CLI tool and shouldn't conflict with the homebrew yubico-yubikey-manager on Darwin

  # Backups
  restic
  autorestic

  # Networking
  tailscale

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

  # Virtualization
  # qemu
  # libvirt
  # edk2
  # virt-manager # Broken on Darwin

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
]
