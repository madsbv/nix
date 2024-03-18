# TODO
- [x] Learn secrets management using age
- [ ]   Document secrets management process
- [ ] Set up gpg and agent (Can we get away with not doing that? I think it's only use for .authinfo in some Emacs thing right now (related to mbsync?), can we replace with something else, e.g. age?)
- [x] ZSH autocompletion/suggestion, zplug, ...
- [ ] Set up Just
- [ ]   E.g. something like this for config tinkering: https://nixos-and-flakes.thiscute.world/best-practices/accelerating-dotfiles-debugging
- [x] Theming, Base16 (see base16.nix, nix-colors, stylix)
- [ ] Backup/restic/autorestic
- [ ] Add nix-options-search to nixpkgs
- [ ] Can we install cargo packages directly from nix?

Refactoring
- [ ] Figure out how to arrange system vs home-manager modules better. 
- [ ] Split modules into individual apps, using imports/options/config syntax

VM/multihost
- [ ] Experiment with setting up a NixOS guest in VM, e.g. for accessing performance profiling tools
