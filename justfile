# TODO: Make this system agnostic (probably requires generating it from nix)
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

default: check-all

run *args:
	nix run --show-trace --inputs-from . {{args}}

build *args:
	nix --extra-experimental-features 'nix-command flakes' build --show-trace {{args}}

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

alias c := check
check: lint
	nix flake check --show-trace

alias ca := check-all
check-all *args: lint
	nix flake check --all-systems --show-trace {{args}}

alias y := fix-yabai
fix-yabai:
	launchctl kickstart -k gui/501/org.nixos.yabai
	launchctl kickstart -k gui/501/org.nixos.sketchybar

alias bd := build-darwin
build-darwin:
	just build ".#darwinConfigurations.mbv-mba.system"

alias sd := switch-darwin
switch-darwin: rekey
	darwin-rebuild switch --show-trace --flake .#mbv-mba

alias sn := switch-nixos
switch-nixos:
	nixos-rebuild switch --show-trace --flake .#$(hostname)

alias d := deploy
deploy:
	just run github:serokell/deploy-rs -- --skip-checks --checksigs .

alias dh := deploy-host
deploy-host hostname:
	just run github:serokell/deploy-rs ".#{{hostname}}"

alias dd := deploy-dry
deploy-dry:
	just run github:serokell/deploy-rs -- --dry-activate --debug-logs .

alias u := update
update:
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
rekey *args:
	just run "agenix-rekey#packages.aarch64-darwin.default" -- rekey -a {{args}}

alias e := agenix-edit
agenix-edit *args:
	just run "agenix-rekey#packages.aarch64-darwin.default" -- edit {{args}}

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
