# TODO
- [ ] Just recipe for config tinkering: https://nixos-and-flakes.thiscute.world/best-practices/accelerating-dotfiles-debugging
- [ ] Can we install cargo packages directly from nix?
- [ ] Disk encryption on nixos machines?
- [ ] Can we do multi-key shortcuts with skhd, e.g., 'alt-1 alt-2' for switching to space 12? Else consider adding some function key shortcuts for use with Glove80, like F10-F18 or whatever, or even duplicating the 1-9 bindings on function keys.
        - We can also do 1-0 for one screen and F1-F10 for the other.

Refactoring
- [ ] Split modules into individual apps, using imports/options/config syntax

## Plan of attack for servers
Next steps:
2. ~~Use mbv-xps13 as deployer to desktop with nixos-anywhere, test and document that installation flow.~~
3.  ~~Consider keeping Gentoo installation around, or at least backing up stuff like game saves.~~
4. ~~Set up deploy-rs to manage deployments to every system at once.~~
6. Set up home-assistant on xps13.
7. Set up something like Ollama on desktop for LLM stuff.
  - Ollama as server is up and running on mbv-desktop:11434 (I think, double check the port). Figure out how to set up clients to use it, e.g. emacs and raycast

### Note on DNS and Tailscale
https://github.com/tailscale/tailscale/issues/1543
The issue above tracks implementation of user-configurable DNS records on the tailnet. This plus a reverse proxy would make it possible to host multiple services on a single machine, with appropriate hostnames.

I see two alternatives until this gets implemented:
- Run a local DNS server on the tailnet. Requires some kind of forwarding/split-dns type stuff probably.
- Run services in VMs/microvms each with a Tailscale client and hostname set as appropriate for the service.


## Media server
Want:
- Play stuff on TV, remote controlled. Plex?
- github.com/Spotifyd/spotifyd might be fun to have running?

# NixOS-anywhere issue

I tested deploying to desktop with nixos-anywhere. I ran into two issues.

1. The nixos-anywhere function to copy ssh host keys to the installation didn't work, presumably because of the tmpfs root wiping stuff out? I think we can fix this by halting nixos-anywhere before rebooting into new system and copying stuff over ourselves, maybe with a script.
2. Desktop didn't have any DHCP resolution on boot. I fixed this by adding a file to /etc/systemd/network/ with the contents

``` toml
[Match]
Name=eno1

[Network]
dhcp=yes
```
(The last line might not be quite right). I think this can be fixed by either enabling networkmanager even for non-wifi systems (my chosen solution for now), or by adding a [Network] section to systemd.network.config enabling DHCP globally.

# Keyboard layouts

Problem: With HRMs, distinguishing between left and rignt cmd becomes difficult, and that was kind of arbitrary in the first place. Let's replace the window management/yabai stuff on lcmd with alt and use cmd for application specific things.

Along the way we can switch lalt and lcmd on internal keyboard in karabiner. Eventually we can go to HRM using kmonad and use the cmd keys for layers, e.g. symbol layer.

1. ~~Switch skhd and karabiner settings as above (optionally remove a bunch of unused vim-mode stuff)~~
2. ~~Add hrm to glove~~
3. Switch to kmonad on internal keyboard with hrm. At this point we should probably switch to HRM entirely and have a navigation layer. This means that there's no reason to spend time cleaning up Karabiner config.

# Glove80 layout changes

- [x] Add a Notarise layout layer: https://sites.google.com/alanreiser.com/handsdown/home/more-variations?authuser=0
- [x] Added Handsdown Neu; Vibranium requires a bunch of complex shit like combos
- [x] Consider what to add to RH of symbol layer
  - [x] Added & to index
  - [x] Added ! to RH middle finger on symbol layer
- Add alt-tab and alt-shift-tab to skhd/yabai instead of/in addition to alt-n and alt-p? Although shift-tab causes some modifier issues with moving windows/spaces

Glove/SKHD idea: Move/copy hjkl/s/np bindings to arrows/page up/down/home/end like that which are on the cursor layer, and more space options on function keys; then our window management is all on LH alt+thumb and right hand.

# Yabai/SKHD/Sketchybar

- [ ] Have Sketchybar display different colors for active and inactive display
- [ ] Figure out how to make Yabai behave better with multiple monitors, e.g. be able to move to `other monitor` instead of `recent monitor`.
- [ ] Tame Yabai/darwin's weird behaviour regarding moving between spaces erratically when trying to do stuff on empty spaces.
- [ ]   If we can't change the existing behaviour, we could try to adopt a workflow that includes closing, reopening and moving spaces a lot more
