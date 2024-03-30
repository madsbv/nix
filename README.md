# TODO
- [ ] Add $HOME/.authinfo to agenix-rekey setup. Store in plaintext on disk.
- [ ] Set up Just
- [ ]   E.g. something like this for config tinkering: https://nixos-and-flakes.thiscute.world/best-practices/accelerating-dotfiles-debugging
- [x] Theming, Base16 (see base16.nix, nix-colors, stylix)
- [ ] Backup/restic/autorestic
- [ ] Add nix-options-search to nixpkgs
- [ ] Can we install cargo packages directly from nix?
- [ ] Get a NixOS VM setup going in the flake somehow.
- [ ]   Write a Just recipe for spinning it up and down, ideally just in the background.

Refactoring
- [ ] Figure out how to arrange system vs home-manager modules better. 
- [ ] Split modules into individual apps, using imports/options/config syntax

Tailscale: On clients we'll just use the client with `tailscale up`. On servers we'll use an authkey, and for VMs (except maybe a fixed build VM on Darwin), use an ephemeral key.
