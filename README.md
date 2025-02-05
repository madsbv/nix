# TODO
- [ ] Just recipe for config tinkering: https://nixos-and-flakes.thiscute.world/best-practices/accelerating-dotfiles-debugging
- [ ] Can we install cargo packages directly from nix?
- [ ] Disk encryption on nixos machines?
- [ ] Can we do multi-key shortcuts with skhd, e.g., 'alt-1 alt-2' for switching to space 12? Else consider adding some function key shortcuts for use with Glove80, like F10-F18 or whatever, or even duplicating the 1-9 bindings on function keys.
        - We can also do 1-0 for one screen and F1-F10 for the other.
- [ ] Try to figure out patching nixpkgs and nix-darwin to pull in pull requests early on build failures, see [nixpkgs patching](#nixpkgs patching). 

## nixpkgs patching
The following was some code and comments from an attempt on 250101 to do this.
I think I can probably figure out how to inject the patched nixpkgs/pkgs into the nixos systems, but I can't figure out how to inject nixpkgs to nix-darwin, other than as a flake input, which I don't think I can patch.

I can inject pkgs to darwinSystem (just with inherit pkgs), but the system still uses nixpkgs from its flake input, so pkgs and nixpkgs get disconnected. In particular, settings in nixpgks.config in the system configuration don't apply to the injected instance of pkgs. The exact issue I faced was inability to set `allowUnfree = true`.

``` nix
      ### Apply nixpkgs patches/pull requests before they make their way to the normal channels (e.g. nixpkgs-unstable).
      # Based on:
      # https://ertt.ca/nix/patch-nixpkgs
      # https://wiki.nixos.org/wiki/Nixpkgs/Patching_Nixpkgs
      # For a given pull request on Github, append '.patch' to get a corresponding patch file. Download it and add it to the ./patches folder in this repo and add to the patches list below.
      #
      # XXX: I don't know how to make this work with nix-darwin. I think I can pass a patched pkgs to it, but it still uses its own flake input for nixpkgs.lib, which means that nixpkgs.config settings inside the system config don't apply to the patched pkgs, since it uses its own lib.
      nixpkgs-patched =
        system:
        (import nixpkgs {
          inherit system;
        }).applyPatches
          {
            name = "nixpkgs-patched";
            src = nixpkgs;
            patches = [
              ./patches/nixpkgs-369649-libossp-uuid.patch
            ];
          };
      pkgs-patched = system: import (nixpkgs-patched system) { inherit system; };
```


## Servers
6. Set up home-assistant on xps13.
8. [ ] Set up one of the servers as substituter for everything else--No reason to build everything twice.

### Note on DNS and Tailscale
https://github.com/tailscale/tailscale/issues/1543
The issue above tracks implementation of user-configurable DNS records on the tailnet. This plus a reverse proxy would make it possible to host multiple services on a single machine, with appropriate hostnames.

I see two alternatives until this gets implemented:
- Run a local DNS server on the tailnet. Requires some kind of forwarding/split-dns type stuff probably.
- Run services in VMs/microvms each with a Tailscale client and hostname set as appropriate for the service.



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
3. Switch to kmonad on internal keyboard with hrm. At this point we should probably switch to HRM entirely and have a navigation layer. This means that there's no reason to spend time cleaning up Karabiner config.
As part of this, add a navigation and a symbol layer in kmonad

# Glove80 layout changes
Glove/SKHD idea: Move/copy hjkl/s/np bindings to arrows/page up/down/home/end like that which are on the cursor layer, and more space options on function keys; then our window management is all on LH alt+thumb and right hand.

# Yabai/SKHD/Sketchybar
- [ ] Have Sketchybar display different colors for active and inactive display
- [ ] Figure out how to make Yabai behave better with multiple monitors, e.g. be able to move to `other monitor` instead of `recent monitor`.
- [ ] Tame Yabai/darwin's weird behaviour regarding moving between spaces erratically when trying to do stuff on empty spaces.
- [ ]   If we can't change the existing behaviour, we could try to adopt a workflow that includes closing, reopening and moving spaces a lot more
- [ ] Make use of some function layer keys on the Glove to have shortcuts to go to browser, emacs, and maybe signal? I'm thinking of the current 'web browser', 'calculator', and 'my pc' buttons. Might need to rebind these in Glove.
