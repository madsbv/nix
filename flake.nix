{
  description = "Starter Configuration with secrets for MacOS and NixOS";
  inputs = {
    ### Nix basics ###
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Local copy of fork of nixpkgs for development/testing package upgrades
    #nixpkgs.url = "github:madsbv/nixpkgs/emacs-no-titlebar-patch";
    # nixpkgs.url = "git+file:///Users/mvilladsen/workspace/github.com/madsbv/nixpkgs/";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Darwin ###
    darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew = { url = "github:zhaofengli-wip/nix-homebrew"; };
    homebrew-bundle = {
      url = "github:homebrew/homebrew-bundle";
      flake = false;
    };
    homebrew-core = {
      url = "github:homebrew/homebrew-core";
      flake = false;
    };
    homebrew-cask = {
      url = "github:homebrew/homebrew-cask";
      flake = false;
    };
    homebrew-services = {
      url = "github:homebrew/homebrew-services";
      flake = false;
    };
    homebrew-cask-fonts = {
      url = "github:homebrew/homebrew-cask-fonts";
      flake = false;
    };
    felixkratz-formulae = {
      url = "github:felixkratz/homebrew-formulae";
      flake = false;
    };
    pirj-noclamshell = {
      url = "github:pirj/homebrew-noclamshell";
      flake = false;
    };

    ### NixOS ###
    # Declarative disk partitioning in nixos
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    # For building VMs and install ISOs
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Theming ###
    base16.url = "github:SenchoPens/base16.nix";
    # Color schemes
    base16-schemes = {
      url = "github:tinted-theming/schemes";
      flake = false;
    };
    base16-vim = {
      url = "github:tinted-theming/base16-vim";
      flake = false;
    };
    base16-kitty = {
      url = "github:kdrag0n/base16-kitty";
      flake = false;
    };

    ### Other ###
    doomemacs = {
      url = "github:doomemacs/doomemacs";
      flake = false;
    };
    fenix = {
      url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Personal config ###
    my-doomemacs-config = {
      url = "github:madsbv/doom.d";
      flake = false;
    };
  };
  outputs = { self, nixos-generators, impermanence, darwin, nix-homebrew
    , home-manager, nixpkgs, agenix, agenix-rekey, disko, ... }@inputs:
    let
      # color-scheme = "${inputs.base16-schemes}/base16/monokai.yaml";
      molokai = {
        slug = "molokai";
        scheme = "Port of the Doomemacs port of Tomas Restrepo's Molokai";
        author = "madsbv";
        base00 = "#1c1e1f";
        base01 = "#222323";
        base02 = "#4e4e4e";
        base03 = "#555556";
        base04 = "#767679";
        base05 = "#d6d6d4";
        base06 = "#f5f4f1";
        base07 = "#ffffff";
        base08 = "#fb2874";
        base09 = "#fd971f";
        base0A = "#e2c770";
        base0B = "#b6e63e";
        base0C = "#66d9ef";
        base0D = "#268bd2";
        base0E = "#9c91e4";
        base0F = "#cc6633";
      };
      color-scheme = molokai;
      linuxSystems = [ "x86_64-linux" "aarch64-linux" ];
      darwinSystems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      forLinuxSystems = f: nixpkgs.lib.mergeAttrsList (map f linuxSystems);

      devShell = system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            packages = with pkgs; [
              zsh
              git
              age-plugin-yubikey
              agenix-rekey.packages.${system}.default
              statix
              deadnix
            ];

            # nix develop enters a bash shell by default. This gets us back to zsh. The `exec` *replaces* the running bash instance with zsh; without it we'd have to exit twice to get back to original shell.
            shellHook = ''
              exec ${pkgs.zsh}/bin/zsh
            '';
          };
        };
      nodes = {
        clients = [ "mbv-mba" ];
        servers = [ "mbv-xps13" ];
      };
    in {
      devShells = forAllSystems devShell;

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nodes = self.darwinConfigurations // {
          inherit (self.nixosConfigurations) mbv-xps13;
        };
      };

      darwinConfigurations = {
        mbv-mba = darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = inputs // {
            inherit color-scheme nodes;
            flake-inputs = inputs;
            flake-root = ./.;
            hostname = "mbv-mba";
          };
          modules = [
            ./hosts/darwin
            home-manager.darwinModules.home-manager
            nix-homebrew.darwinModules.nix-homebrew
            agenix.darwinModules.default
            agenix-rekey.nixosModules.default
            inputs.base16.nixosModule
            { scheme = color-scheme; }
          ];
        };
      };

      nixosConfigurations = {
        mbv-xps13 = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = inputs // {
            inherit nodes;
            flake-inputs = inputs;
            flake-root = ./.;
            hostname = "mbv-xps13";
          };
          modules = [
            ./hosts/mbv-xps13
            home-manager.nixosModules.home-manager
            agenix.nixosModules.default
            agenix-rekey.nixosModules.default
            impermanence.nixosModules.impermanence
            disko.nixosModules.disko
          ];
        };
      } // forLinuxSystems (system: {
        # A system configuration for ephemeral systems--either temporary VMs or for installers.
        # Use nixos-generators to build a VM or ISO with
        # `nix build .#nixosConfigurations.ephemeral.config.formats.<format>`
        # Supported formats: https://github.com/nix-community/nixos-generators?tab=readme-ov-file#supported-formats
        # Example formats: install-iso qcow-efi (for qemu vm)
        "ephemeral-${system}" = nixpkgs.lib.nixosSystem {
          inherit system;

          # For VMs
          # Specific formats can be configured with something like:
          # formatConfigs.vmware = { config, ... }: {
          #   services.openssh.enable = true;
          # };
          # nixpkgs.hostPlatform = "aarch64-darwin";
          specialArgs = {
            inherit inputs system;
            flake-inputs = inputs;
            flake-root = ./.;
            hostname = "ephemeral";
          };
          modules = [
            impermanence.nixosModules.impermanence
            nixos-generators.nixosModules.all-formats
            disko.nixosModules.disko
            ./ephemeral/configuration.nix
          ];
        };
      });
    };
}
