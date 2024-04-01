# TODO: Make this system agnostic (probably requires generating it from nix)

default: switch

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
check-all: lint
	nix flake check --all-systems

alias y := fix-yabai
fix-yabai:
	launchctl kickstart -k gui/501/org.nixos.yabai
	launchctl kickstart -k gui/501/org.nixos.sketchybar

alias b := build
build:
	nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.mbv-mba.system

# Invoke the recipes `rekey` and `build`, in that order, before invoking the body of `switch`
# Default command, so no need to define alias
switch: rekey
	darwin-rebuild switch --flake .#mbv-mba

alias be := build-ephemeral
build-ephemeral type format="install-iso": rekey
	rage -d -i pubkeys/yubikey/age-yubikey-identity-mba.pub secrets/tailscale/24-03-30-ephemeral-vms-authkey.age > ephemeral/tailscale-auth
	-nix build .#nixosConfigurations.{{type}}-linux.ephemeral.config.formats.{{format}}
	echo "" > ephemeral/tailscale-auth
	-rm ephemeral-{{format}}.iso
	cp result ephemeral-{{format}}.iso
	ln -s ephemeral-{{format}}.iso ~/ephemeral-{{format}}.iso


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

