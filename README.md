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

## Remote build/substituter/general ssh key management thoughts
There are by now many places where we need to specify keys to make everything work. We should write a module that centralizes this in one place.
The module should define lists of keys by role. It should have a "role" option, and depending on its value, various key fields across config should be set.

Keys we need to manage:
- Possibly for serving the store over SSH (i.e., binaries): https://nixos.org/manual/nix/stable/package-management/ssh-substituter.html
-   This might require signing builds with hostkeys, also requires nix-ssh to be a trusted user for remote building.
