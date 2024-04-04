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
	nix flake check --show-trace

alias ca := check-all
check-all *args: lint
	nix flake check --all-systems --show-trace {{args}}

alias y := fix-yabai
fix-yabai:
	launchctl kickstart -k gui/501/org.nixos.yabai
	launchctl kickstart -k gui/501/org.nixos.sketchybar

alias b := build
build *args:
	nix --extra-experimental-features 'nix-command flakes' build --show-trace {{args}} .#darwinConfigurations.mbv-mba.system

alias sd := switch-darwin
switch-darwin: rekey
	darwin-rebuild switch --show-trace --flake .#mbv-mba

alias sn := switch-nixos
switch-nixos:
	nixos-rebuild switch --show-trace --flake .#$(hostname)

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
	nix run --inputs-from . agenix-rekey\#packages.aarch64-darwin.default -- rekey -a {{args}}

alias e := agenix-edit
agenix-edit *args:
	nix run --inputs-from . agenix-rekey\#packages.aarch64-darwin.default -- edit {{args}}

alias un := update-nixos
update-nixos: && switch-nixos
	nix flake update

alias ud := update-darwin
update-darwin: && switch-darwin
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
