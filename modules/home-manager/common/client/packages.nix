{ pkgs, nox, ... }:

[ nox ]
++ (with pkgs; [
  # Communication tools
  zoom-us
  discord

  # Clipboard management from terminal and neovim
  xsel

  # Media-related packages
  ffmpeg
  imagemagick
  graphviz
  portaudio
  multimarkdown
  pandoc
  fontconfig
  spotify

  # Writing
  # Function provided by nixpkgs. Required to build aspell together with its dictionaries, otherwise they will be isolated from each other in the nix store.
  # en-computers and en-science are two special dictionaries (and the only ones provided) for computer and science jargon.
  (aspellWithDicts (
    dicts: with dicts; [
      en
      en-computers
      en-science
      de
      da
    ]
  ))
  hunspell
  languagetool
  enchant
  bibutils
  stylelint
  texlab
  texliveFull
  # TODO 241020: Build errors: https://github.com/NixOS/nixpkgs/issues/339576
  # bitwarden-cli

  # Documents
  djvulibre
  poppler

  # 3D modelling
  # unstable is currently broken on Darwin: https://github.com/NixOS/nixpkgs/pull/342211#issuecomment-2356528216
  # openscad-unstable
  # Stable seems to also be broken
  # openscad
])
