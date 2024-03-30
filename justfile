# TODO: Make this system agnostic (probably requires generating it from nix)

lint:
	nix run --inputs-from . nixpkgs#deadnix
	nix run --inputs-from . nixpkgs#statix -- check

fix:
	nix run --inputs-from . nixpkgs#deadnix -- -e
	nix run --inputs-from . nixpkgs#statix -- fix

check: lint
	nix flake check

check-all: lint
	nix flake check --all-systems

fix-yabai:
	launchctl kickstart -k gui/501/org.nixos.yabai
	launchctl kickstart -k gui/501/org.nixos.sketchybar

build:
	nix --extra-experimental-features 'nix-command flakes' build .#darwinConfigurations.macos.system

rekey:
	nix run --inputs-from . agenix-rekey\#packages.aarch64-darwin.default -- rekey -a

# Invoke the recipes `rekey` and `build`, in that order, before invoking the body of `switch`
switch: rekey build
	./result/sw/bin/darwin-rebuild switch --flake .#macos

# Every recipe after && it invoked at the the end of this recipe
update: && switch
	nix flake update

