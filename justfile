# TODO: Make this system agnostic (probably requires generating it from nix)

default: switch-darwin

alias l := lint
lint:
	nix run --inputs-from . nixpkgs#deadnix
	nix run --inputs-from . nixpkgs#statix -- check

alias f := fix
fix:
	nix run --inputs-from . nixpkgs#deadnix -- -e
	nix run --inputs-from . nixpkgs#statix -- fix

alias c := check
check: lint
	nix flake check

alias ca := check-all
check-all *args: lint
	nix flake check --all-systems {{args}}

alias y := fix-yabai
fix-yabai:
	launchctl kickstart -k gui/501/org.nixos.yabai
	launchctl kickstart -k gui/501/org.nixos.sketchybar

alias b := build
build:
	nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.mbv-mba.system

# Invoke the recipes `rekey` and `build`, in that order, before invoking the body of `switch`
# Default command, so no need to define alias
switch-darwin: rekey
	darwin-rebuild switch --flake .#mbv-mba

alias sn := switch-nixos
switch-nixos:
	nixos-rebuild switch --flake .#$(hostname)

alias be := build-ephemeral
build-ephemeral type format="install-iso": rekey
	rage -d -i pubkeys/yubikey/age-yubikey-identity-mba.pub secrets/tailscale/24-03-30-ephemeral-vms-authkey.age > ephemeral/tailscale-auth
	-nix build .#nixosConfigurations.ephemeral-{{type}}-linux.config.formats.{{format}}
	echo "" > ephemeral/tailscale-auth
	mkdir -p ~/ephemeral
	-rm -f ~/ephemeral/ephemeral-{{type}}-{{format}}.iso
	cp result ~/ephemeral/ephemeral-{{type}}-{{format}}.iso
	chmod +w ~/ephemeral/ephemeral-{{type}}-{{format}}.iso

alias r := rekey
rekey *flags:
	nix run --inputs-from . agenix-rekey\#packages.aarch64-darwin.default -- rekey -a {{flags}}

alias e := agenix-edit
agenix-edit *flags:
	nix run --inputs-from . agenix-rekey\#packages.aarch64-darwin.default -- edit {{flags}}

# Every recipe after && it invoked at the the end of this recipe
alias u := update
update: && switch
	nix flake update

nixos-anywhere host target: rekey
	nix run github:nix-community/nixos-anywhere -- --copy-host-keys --build-on-remote --flake '.#{{host}}' root@{{target}}

disko-install host disk:
	nix run github:nix-community/disko#disko-installer -- --disk {{disk}} /dev/{{disk}} --extra-files /etc/ssh /etc/ssh --write-efi-boot-entries --show-trace -f .#{{host}}

# TODO: Add a step to copy over github ssh key for temporary access for installation?
# Could also do networkmanager wifi info
new-host hostname target:
	ssh root@{{target}} "nixos-generate-config --no-filesystems --root /mnt"
	ssh root@{{target}} 'NIX_CONFIG="experimental-features = nix-command flakes" nix run nixpkgs#tree /dev/disk > /mnt/etc/nixos/tree'
	ssh root@{{target}} 'lsblk > /mnt/etc/nixos/lsblk'
	ssh root@{{target}} 'hostid > /mnt/etc/nixos/hostid'
	ssh root@{{target}} 'cp /etc/ssh/ssh_host_ed25519_key.pub /mnt/etc/nixos/'
	-rm -rf new-host-{{hostname}}
	scp -r root@{{target}}:/mnt/etc/nixos new-host-{{hostname}}
	-rm pubkeys/ssh/ssh_host_ed25519_key.pub.{{hostname}}
	cp new-host-{{hostname}}/ssh_host_ed25519_key.pub pubkeys/ssh/ssh_host_ed25519_key.pub.{{hostname}}
