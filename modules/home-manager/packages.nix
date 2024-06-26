{ pkgs, ... }:

with pkgs;
[
  # Communication tools
  zoom-us
  discord

  # Media-related packages
  ffmpeg
  imagemagick
  graphviz
  portaudio
  multimarkdown
  pandoc
  fontconfig

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
  # TODO: 240618:Fix and reenable
  # bitwarden-cli

  # Documents
  djvulibre
  poppler
]
