{ pkgs }:

with pkgs;
[
  # General packages for development and system management
  bash-completion
  bat
  eza
  zoxide
  btop
  htop
  iftop
  coreutils-full
  parallel-full
  inetutils
  killall
  curlFull
  wget
  gitFull
  zip
  zstd
  unrar
  unzip
  fd
  ripgrep
  # TODO: 241019: Potential build problem on Darwin?
  # ripgrep-all
  fzf
  gdu
  tree
  just
  watchexec
  jq
  zellij
  ## Tool to explore nix expression dependencies.
  ## There's also the built-in `nix path-info -r` and `nix why-depends`
  nix-tree
  # TODO: Do I really need these?
  # sqlite
  # perl

  # Encryption and security tools
  # agenix-rekey
  rage
  age-plugin-yubikey
  # gnupg
  libfido2
  yubikey-agent
  yubikey-manager # Should be a CLI tool and shouldn't conflict with the homebrew yubico-yubikey-manager on Darwin

  # Networking
  tailscale

  # Virtualization
  # TODO: Sort this out
  # qemu
  # libvirt
  # edk2
  # virt-manager # Broken on Darwin
]
