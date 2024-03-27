{
  description =
    "An example of a configured misterio77/nix-starter-config for impermanence, on qemu aarch64-linux vm running on macos host";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    impermanence.url = "github:nix-community/impermanence";
  };

  outputs = inputs@{ nixpkgs, impermanence, ... }: {
    nixosConfigurations = {
      nixos-guest = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";

        # Pass inputs into the NixOS module system
        specialArgs = { inherit inputs; };

        modules =
          [ impermanence.nixosModules.impermanence ./configuration.nix ];
      };
    };
  };
}
