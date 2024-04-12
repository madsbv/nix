# TODO
- [ ] Just recipe for config tinkering: https://nixos-and-flakes.thiscute.world/best-practices/accelerating-dotfiles-debugging
- [ ] Add nix-options-search to nixpkgs
- [ ] Can we install cargo packages directly from nix?
- [ ] Disk encryption on nixos machines?
- [ ] Can we do multi-key shortcuts with skhd, e.g., 'alt-1 alt-2' for switching to space 12? Else consider adding some function key shortcuts for use with Glove80, like F10-F18 or whatever, or even duplicating the 1-9 bindings on function keys.
        - We can also do 1-0 for one screen and F1-F10 for the other.

Refactoring
- [ ] Split modules into individual apps, using imports/options/config syntax

## Plan of attack for servers
Next steps:
2. Use mbv-xps13 as deployer to desktop with nixos-anywhere, test and document that installation flow.
3.  Consider keeping Gentoo installation around, or at least backing up stuff like game saves.
4. Set up deploy-rs to manage deployments to every system at once.
6. Set up home-assistant on xps13.
7. Set up something like Ollama on desktop for LLM stuff.

### Note on DNS and Tailscale
https://github.com/tailscale/tailscale/issues/1543
The issue above tracks implementation of user-configurable DNS records on the tailnet. This plus a reverse proxy would make it possible to host multiple services on a single machine, with appropriate hostnames.

I see two alternatives until this gets implemented:
- Run a local DNS server on the tailnet. Requires some kind of forwarding/split-dns type stuff probably.
- Run services in VMs/microvms each with a Tailscale client and hostname set as appropriate for the service.

### TODO: Fix currently broken restic backup on mbv-xps13

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

# Keyboard layouts

Problem: With HRMs, distinguishing between left and rignt cmd becomes difficult, and that was kind of arbitrary in the first place. Let's replace the window management/yabai stuff on lcmd with alt and use cmd for application specific things.

Along the way we can switch lalt and lcmd on internal keyboard in karabiner. Eventually we can go to HRM using kmonad and use the cmd keys for layers, e.g. symbol layer.

1. ~~Switch skhd and karabiner settings as above (optionally remove a bunch of unused vim-mode stuff)~~
2. ~~Add hrm to glove~~
3. Switch to kmonad on internal keyboard with hrm. At this point we should probably switch to HRM entirely and have a navigation layer. This means that there's no reason to spend time cleaning up Karabiner config.

# Glove80 layout changes

- Add a Notarise layout layer: https://sites.google.com/alanreiser.com/handsdown/home/more-variations?authuser=0
- Add a Handsdown Vibranium layer
- Try to add a repeat key somewhere
- Change arrow keys on cursor layer to match Vim better
- Consider changing RH of symbol layer to give better bracket/brace access
- Change shift keys on base layer to something more useful, e.g. try one-shot shift, shift-word,...

# Yabai/SKHD/Sketchybar

- [ ] Have Sketchybar display different colors for active and inactive display
- [ ] Figure out how to make Yabai behave better with multiple monitors, e.g. be able to move to `other monitor` instead of `recent monitor`.
- [ ] Tame Yabai/darwin's weird behaviour regarding moving between spaces erratically when trying to do stuff on empty spaces.
- [ ]   If we can't change the existing behaviour, we could try to adopt a workflow that includes closing, reopening and moving spaces a lot more
