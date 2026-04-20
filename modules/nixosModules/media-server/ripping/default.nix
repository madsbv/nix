{
  pkgs,
  ...
}:

{
  # GOAL: Eventually have a system that will automatically detect an inserted cd/dvd/blu-ray, rips, transcodes, tags w/ metadata, then place in jellyfin/beets/other library as appropriate.
  # automatic-ripping-machine sounds like it would solve this: https://github.com/automatic-ripping-machine/automatic-ripping-machine
  # Not yet in nixpkgs: https://github.com/NixOS/nixpkgs/issues/370710
  environment.systemPackages = with pkgs; [
    handbrake
  ];
}
