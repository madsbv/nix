# TODO
- [ ] Add $HOME/.authinfo to agenix-rekey setup. Store in plaintext on disk.
- [ ] Just recipe for config tinkering: https://nixos-and-flakes.thiscute.world/best-practices/accelerating-dotfiles-debugging
- [x] Theming, Base16 (see base16.nix, nix-colors, stylix)
- [ ] Backup/restic/autorestic
- [ ] Add nix-options-search to nixpkgs
- [ ] Can we install cargo packages directly from nix?
- [ ] Disk encryption on nixos machines?

Refactoring
- [ ] Figure out how to arrange system vs home-manager modules better. 
- [ ] Split modules into individual apps, using imports/options/config syntax

## Plan of attack for servers
Next steps:
1. Set up remote builders, possibly over Tailscale.
2. Use mbv-xps13 as deployer to desktop with nixos-anywhere, test and document that installation flow.
3.  Consider keeping Gentoo installation around, or at least backing up stuff like game saves.
4. Set up deploy-rs to manage deployments to every system at once.
5. Set up restic/autorestic as a reasonably portable module, set up on all systems.
6. Set up home-assistant on xps13.
7. Set up something like Ollama on desktop for LLM stuff.

## Media server
Want:
- Play stuff on TV, remote controlled. Plex?
- github.com/Spotifyd/spotifyd might be fun to have running?
