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
    deploy-rs = {
      url = "github:serokell/deploy-rs";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    agenix-rekey = {
      # 250202: Source of PR https://github.com/oddlama/agenix-rekey/pull/73 which adds a subcommand to reencrypt all source secrets with new masterIdentities.
      # url = "github:charludo/agenix-rekey";
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Darwin ###
    darwin = {
      url = "github:LnL7/nix-darwin/";
      # Good commit:
      # url = "github:LnL7/nix-darwin/57733bd1dc81900e13438e5b4439239f1b29db0e";
      # commit be4c1b897accbdfc3429e99b5bd5234c5663776e introduces an openssh module to nix-darwin. However, agenix uses `services.openssh.enable` to detect darwin vs linux, and the introduction of this option seems to break that.

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew = {
      url = "github:zhaofengli-wip/nix-homebrew";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nix-darwin.follows = "darwin";
      };
    };

    homebrew-apple = {
      url = "github:apple/homebrew-apple";
      flake = false;
    };
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

    fenix = {
      # Nightly branch, but only updated once a month to reduce churn
      url = "github:nix-community/fenix/monthly";
      # Up to date nightly branch
      # url = "github:nix-community/fenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bootdev = {
      url = "github:bootdotdev/bootdev";
      flake = false;
    };

    nox = {
      url = "github:madsbv/nix-options-search";
      # url = "git+file:///Users/mvilladsen/workspace/github.com/madsbv/nix-options-search/";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };
  outputs =
    {
      self,
      nixos-generators,
      impermanence,
      darwin,
      nix-homebrew,
      home-manager,
      nixpkgs,
      agenix,
      agenix-rekey,
      disko,
      deploy-rs,
      ...
    }@inputs:
    let
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
      # Use the color scheme defined above
      color-scheme = molokai;
      ## Example of using a color scheme from the base-16 repo:
      # color-scheme = "${inputs.base16-schemes}/base16/monokai.yaml";

      linuxSystems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
      darwinSystems = [ "aarch64-darwin" ];
      forAllSystems = f: nixpkgs.lib.genAttrs (linuxSystems ++ darwinSystems) f;
      forLinuxSystems = f: nixpkgs.lib.mergeAttrsList (map f linuxSystems);

      devShell =
        system:
        let
          pkgs = import nixpkgs { inherit system; };
        in
        {
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

      common-modules = [
        inputs.base16.nixosModule
        { scheme = color-scheme; }
      ];
      darwin-modules = [
        home-manager.darwinModules.home-manager
        nix-homebrew.darwinModules.nix-homebrew
        agenix.darwinModules.default
        agenix-rekey.nixosModules.default
      ] ++ common-modules;
      nixos-modules = [
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        agenix-rekey.nixosModules.default
        impermanence.nixosModules.impermanence
        disko.nixosModules.disko
      ] ++ common-modules;

      common-args = system: {
        inherit nodes color-scheme inputs;
        flake-root = ./.;
        nox = inputs.nox.packages.${system}.default;
        mod = m: ./. + "/modules/${m}";
        user = "mvilladsen";
      };
      darwin-args = common-args;
      nixos-args = common-args;

      nixos-system =
        system: hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = (nixos-args system) // {
            inherit hostname;
          };
          modules = [ ./hosts/${hostname} ] ++ nixos-modules;
        };

      darwin-system =
        system: hostname:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = (darwin-args system) // {
            inherit hostname;
          };
          modules = [ ./hosts/${hostname} ] ++ darwin-modules;
        };

      # NOTE: When adding new nodes, update this, agenix-rekey, and deploy-rs node lists
      # Used to track hostnames of remote builders and of known ssh hosts
      nodes = {
        clients = [ "mbv-mba" ];
        servers = [
          ### Currently offline
          "mbv-desktop"
          "mbv-xps13"
          "mbv-workstation"
          "hp-90"
        ];
      };
    in
    {
      devShells = forAllSystems devShell;

      agenix-rekey = agenix-rekey.configure {
        userFlake = self;
        nixosConfigurations = self.darwinConfigurations // {
          inherit (self.nixosConfigurations)
            mbv-xps13
            mbv-desktop
            mbv-workstation
            hp-90
            ;
        };
      };

      deploy = {
        remoteBuild = true;
        sshUser = "root";
        user = "root";
        # The defaults, set for clarity
        autoRollback = true;
        magicRollback = true;

        # Tweaking
        fastConnection = true;

        # checks = builtins.mapAttrs (system: deployLib: deployLib.deployChecks self.deploy) deploy-rs.lib;
        nodes = {
          # NOTE: In order for a macos system to receive SSH connections, you need to go to System Settings -> General, and turn 'Remote Login' on, and then under the options for remote login, turn on full disk access.
          mbv-mba = {
            # The machine we're deploying from
            hostname = "mbv-mba";
            sshUser = "mvilladsen";
            user = "mvilladsen";
            # NOTE: In principle this should not be necessary since we have turned off password for sudo, but in practice it still seems necessary, even if we can just pass in an empty password
            interactiveSudo = true;
            # remoteBuild = false;
            profiles.system = {
              path = deploy-rs.lib.aarch64-darwin.activate.darwin self.darwinConfigurations.mbv-mba;
            };
          };
          mbv-workstation = {
            hostname = "mbv-workstation";
            profiles.system = {
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.mbv-workstation;
            };
          };
          ### Currently offline
          # mbv-desktop = {
          #   hostname = "mbv-desktop";
          #   profiles.system = {
          #     path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.mbv-desktop;
          #   };
          # };
          mbv-xps13 = {
            hostname = "mbv-xps13";
            profiles.system = {
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.mbv-xps13;
            };
          };
          hp-90 = {
            hostname = "hp-90";
            profiles.system = {
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.hp-90;
            };
          };
        };
      };

      darwinConfigurations = {
        mbv-mba = darwin-system "aarch64-darwin" "mbv-mba";
      };

      nixosConfigurations =
        {
          mbv-workstation = nixos-system "x86_64-linux" "mbv-workstation";
          mbv-desktop = nixos-system "x86_64-linux" "mbv-desktop";
          mbv-xps13 = nixos-system "x86_64-linux" "mbv-xps13";
          hp-90 = nixos-system "x86_64-linux" "hp-90";
        }
        // forLinuxSystems (system: {
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
            specialArgs = (nixos-args system) // {
              inherit system;
              hostname = "ephemeral";
            };
            modules = [
              impermanence.nixosModules.impermanence
              nixos-generators.nixosModules.all-formats
              disko.nixosModules.disko
              ./hosts/ephemeral
            ];
          };
        });
    };
}
