{
  description =
    "An example of a configured misterio77/nix-starter-config for impermanence, on qemu aarch64-linux vm running on macos host";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-23.11";
    impermanence.url = "github:nix-community/impermanence";
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    # Invoke nixos-generator builds with `nix build .#nixosConfigurations.my-machine.config.formats.<format>`
    # Some relevant formats: install-iso, qcow, qcow-efi
  };
  outputs = inputs@{ self, nixpkgs, impermanence, nixos-generators, ... }:
    let path = self.outPath;
    in {
      # A single nixos config outputting multiple formats.
      # Alternatively put this in a configuration.nix.

      nixosConfigurations = {
        nixos-guest = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";

          # Pass inputs into the NixOS module system
          specialArgs = { inherit inputs; };

          modules =
            [ impermanence.nixosModules.impermanence ./configuration.nix ];
        };
      };
      # packages.aarch64-linux = {
      packages.aarch64-linux = {
        installer = nixos-generators.nixosGenerate {
          system = "aarch64-linux";

          format = "install-iso";

          # Pass inputs into the NixOS module system
          specialArgs = { inherit inputs path; };
          modules = [ ./install-script.nix ];
        };
      };
    };
}
