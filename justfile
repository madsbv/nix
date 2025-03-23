# TODO: Make this system agnostic (probably requires generating it from nix)
# IDEA: We could have files named "justfile-hostname" for each hostname together with a "justfile-common", and generate "justfile" from nix which just contains import statements for "justfile-common" and for the correct "justfile-hostname".
#
# TODO: Set up nix shell and nix-direnv, then use something like this in justfile to make sure we're actually in nix shell when necessary: https://notes.abhinavsarkar.net/2022/just-nix-podman-combo
# Moving to this setup would simplify dev a lot
#
# Dependencies:
# - parallel
# - fd
# - nixfmt-rfc-style
# - deadnix
# - statix
# - deploy-rs
# - agenix-rekey
#
# Rarely used dependencies (should probably remain as `nix run` calls):
# - disko#disko-installer
# - nixos-anywhere

default:
	just --list

run *args: check-git
	nix run --inputs-from . {{args}}

build *args: check-git
	nix --extra-experimental-features 'nix-command flakes' build {{args}}

alias l := lint
lint:
	just run nixpkgs#deadnix
	just run nixpkgs#statix -- check

alias f := fix
fix:
	just run nixpkgs#deadnix -- -e
	just run nixpkgs#statix -- fix
	fd .nix$ | parallel 'just run nixpkgs#nixfmt-rfc-style -- {}'

# https://github.com/DeterminateSystems/flake-checker
# Health check for flake.lock
nfc:
	just run github:DeterminateSystems/flake-checker

# Lists all files that are neither tracked nor ignored. These will not be seen by nix, which might cause silent and confusing errors.
check-git:
	@if [[ -n $(git ls-files . --exclude-standard --others) ]]; then echo "The following files are not tracked and not ignored:"; git ls-files . --exclude-standard --others; exit 1; fi

alias c := check
check: check-git lint
	nix flake check

alias ca := check-all
check-all *args: check-git lint
	nix flake check --all-systems {{args}}

alias y := fix-yabai
fix-yabai:
	launchctl kickstart -k gui/501/org.nixos.yabai
	launchctl kickstart -k gui/501/org.nixos.sketchybar

alias bd := build-darwin
build-darwin *args:
	just build {{args}} ".#darwinConfigurations.mbv-mba.system"

alias sd := switch-darwin
switch-darwin: rekey
	darwin-rebuild switch --flake .#mbv-mba

build-nixos: check-git
	nixos-rebuild build --flake .#$(hostname)

alias sn := switch-nixos
switch-nixos:
	sudo nixos-rebuild switch --flake .#$(hostname)

switch-nixos-boot:
	sudo nixos-rebuild boot --flake .#$(hostname)

alias d := deploy
deploy:
	just run github:serokell/deploy-rs -- --skip-checks --checksigs .

alias dh := deploy-host
deploy-host hostname:
	just run github:serokell/deploy-rs ".#{{hostname}}"

alias dnl := deploy-non-laptops
deploy-non-laptops:
	just deploy-host mbv-xps13
	just deploy-host hp-90
	# just deploy-host mbv-desktop
	just deploy-host mbv-workstation

alias dd := deploy-dry
deploy-dry:
	just run github:serokell/deploy-rs -- --dry-activate --debug-logs .

alias u := update
update: check-git
	nix flake update

alias un := update-nixos
update-nixos: update switch-nixos

alias ud := update-darwin
update-darwin: update switch-darwin

alias be := build-ephemeral
build-ephemeral machine-type image-format="install-iso": rekey
	rage -d -i pubkeys/yubikey/age-yubikey-identity-mba.pub secrets/tailscale/24-03-30-ephemeral-vms-authkey.age > ephemeral/tailscale-auth
	-nix build --fallback .#nixosConfigurations.ephemeral-{{machine-type}}-linux.config.formats.{{image-format}}
	echo "" > ephemeral/tailscale-auth
	mkdir -p ~/ephemeral
	-rm -f ~/ephemeral/ephemeral-{{machine-type}}-{{image-format}}.iso
	cp result ~/ephemeral/ephemeral-{{machine-type}}-{{image-format}}.iso
	chmod +w ~/ephemeral/ephemeral-{{machine-type}}-{{image-format}}.iso

alias r := rekey
rekey *args: check-git
	# just run "agenix-rekey#packages.aarch64-darwin.default" -- rekey -a {{args}}
	just run "agenix-rekey" -- rekey -a {{args}}

alias e := agenix-edit
agenix-edit *args:
	# just run "agenix-rekey#packages.aarch64-darwin.default" -- edit {{args}}
	just run "agenix-rekey" -- edit {{args}}
	git add {{args}}

### USAGE
# Run `j new-host host` first, set up configuration files and disko, and add host key and possibly client ssh keys to config. Then run nixos-anywhere.
# You may need to temporarily disable some pieces of software to make this build, since the ephemeral environment has limited storage space available.
nixos-anywhere host target="ephemeral": rekey
	just run github:nix-community/nixos-anywhere -- --copy-host-keys --build-on-remote --flake '.#{{host}}' root@{{target}}

disko-install host disk:
	just run github:nix-community/disko#disko-installer -- --disk {{disk}} /dev/{{disk}} --extra-files /etc/ssh /etc/ssh --write-efi-boot-entries --show-trace -f .#{{host}}

# TODO: Add a step to copy over github ssh key for temporary access for installation?
# Could also do networkmanager wifi info
new-host hostname target="ephemeral":
	ssh root@{{target}} "nixos-generate-config --no-filesystems --root /mnt"
	ssh root@{{target}} 'NIX_CONFIG="experimental-features = nix-command flakes" nix run nixpkgs#tree /dev/disk > /mnt/etc/nixos/tree'
	ssh root@{{target}} 'lsblk > /mnt/etc/nixos/lsblk'
	ssh root@{{target}} 'hostid > /mnt/etc/nixos/hostid'
	ssh root@{{target}} 'cp /etc/ssh/ssh_host_ed25519_key.pub /mnt/etc/nixos/'
	-rm -rf new-host-{{hostname}}
	scp -r root@{{target}}:/mnt/etc/nixos new-host-{{hostname}}
	-rm pubkeys/ssh/ssh_host_ed25519_key.pub.{{hostname}}
	cp new-host-{{hostname}}/ssh_host_ed25519_key.pub pubkeys/ssh/ssh_host_ed25519_key.pub.{{hostname}}

# NOTE: To configure p10k, run `just p10k-configure`, then `p10k configure`, then `just p10k-finalize` when ready do deploy. You can use p10k-save to save a config even if you're not ready to deploy the whole flake yet.

p10k-configure:
	sudo rm -r $ZDOTDIR/plugins/powerlevel10k-config
	cp -r ./config/p10k $ZDOTDIR/plugins/powerlevel10k-config

p10k-save:
	cp $ZDOTDIR/plugins/powerlevel10k-config/p10k.zsh ./config/p10k/p10k.zsh

p10k-finalize: p10k-save && switch-darwin
	rm -r $ZDOTDIR/plugins/powerlevel10k-config

alias ap := appdaemon-push
appdaemon-push:
	@echo "If permission error, ssh to mbv-xps13 and 'chown -R hass /etc/appdaemon; chgrp -R hass /etc/appdaemon'"
	rsync -rz --delete  modules/services/home-assistant/appdaemon/apps/ mbv-xps13:/etc/appdaemon/apps
