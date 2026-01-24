{
  description = "Configuration with secrets for MacOS and NixOS";
  inputs = {
    ### Nix basics ###
    nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      # url = "github:nix-community/home-manager";
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
      url = "github:oddlama/agenix-rekey";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-auth = {
      url = "github:numtide/nix-auth";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ### Darwin ###
    darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-25.11";

      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-homebrew.url = "github:zhaofengli-wip/nix-homebrew";

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
    impermanence = {
      url = "github:nix-community/impermanence";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };
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

    nox = {
      url = "github:madsbv/nix-options-search";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    hosts = {
      url = "github:StevenBlack/hosts"; # or a fork/mirror
      inputs.nixpkgs.follows = "nixpkgs";
    };
    direnv-instant = {
      url = "github:Mic92/direnv-instant";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        treefmt-nix.inputs.nixpkgs.follows = "nixpkgs";
      };
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
      nix-auth,
      hosts,
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
              git
              age-plugin-yubikey
              agenix-rekey.packages.${system}.default
              deploy-rs.packages.${system}.default
              nix-auth.packages.${system}.default
              statix
              deadnix
              nixfmt-tree
              just
            ];
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
      ]
      ++ common-modules;
      nixos-modules = [
        home-manager.nixosModules.home-manager
        agenix.nixosModules.default
        agenix-rekey.nixosModules.default
        impermanence.nixosModules.impermanence
        disko.nixosModules.disko
        hosts.nixosModule
      ]
      ++ common-modules;

      common-args = system: {
        inherit nodes color-scheme inputs;
        flake-root = ./.;
        nox = inputs.nox.packages.${system}.default;
        mod = m: ./. + "/modules/${m}";
        user = "mvilladsen";
        # Pass module collections for easy access
        modules = self.moduleCollections;
        # Pass individual modules for granular access
        moduleExports = self.modules;
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
        clients = [
          "mbv-mba"
          "mbv-workstation"
        ];
        servers = [
          "mbv-desktop"
          "mbv-xps13"
          "hp-90"
        ];
        buildMachines = [
          "mbv-workstation"
          "mbv-xps13"
        ];
      };
    in
    {
      # Top-level module exports
      modules = {
        # NixOS modules
        nixos = {
          system = import ./modules/system/common/common/default.nix;
          nixos-common = import ./modules/system/nixos/common/default.nix;
          client = import ./modules/system/nixos/client/default.nix;
          server = import ./modules/system/nixos/server/default.nix;
          common-restic = import ./modules/system/nixos/common/restic.nix;
          common-wifi = import ./modules/system/nixos/common/wifi.nix;
          client-yubikey = import ./modules/system/nixos/client/yubikey.nix;
          server-laptop = import ./modules/system/nixos/server/laptop.nix;
          common-laptop = import ./modules/system/nixos/common/laptop.nix;
          server-secrets = import ./modules/system/nixos/server/secrets.nix;
        };

        # Darwin modules
        darwin = {
          system = import ./modules/system/nix-darwin/default.nix;
          homebrew = import ./modules/system/nix-darwin/homebrew/default.nix;
          homebrew-casks = import ./modules/system/nix-darwin/homebrew/casks.nix;
          dock = import ./modules/system/nix-darwin/dock/default.nix;
          autorestic = import ./modules/system/nix-darwin/autorestic.nix;
        };

        # Home-manager modules
        home-manager = {
          common = import ./modules/home-manager/common/common/default.nix;
          client = import ./modules/home-manager/common/client/default.nix;
          client-packages = import ./modules/home-manager/common/client/packages.nix;
          client-email = import ./modules/home-manager/common/client/email.nix;
          client-secrets-email = import ./modules/home-manager/common/client/secrets/email.nix;
          darwin = import ./modules/home-manager/darwin/default.nix;
          darwin-packages = import ./modules/home-manager/darwin/packages.nix;
          nixos-client = import ./modules/home-manager/nixos/client/default.nix;
          nixos-client-dropbox = import ./modules/home-manager/nixos/client/dropbox.nix;
          nixos-common = import ./modules/home-manager/nixos/common/default.nix;
        };

        # Cross-platform modules
        dev = import ./modules/dev/default.nix;
        dev-fortran = import ./modules/dev/fortran/default.nix;
        dev-docker = import ./modules/dev/docker/default.nix;
        dev-go = import ./modules/dev/go/default.nix;
        dev-java = import ./modules/dev/java/default.nix;
        dev-javascript = import ./modules/dev/javascript/default.nix;
        dev-lua = import ./modules/dev/lua/default.nix;
        dev-nix = import ./modules/dev/nix/default.nix;
        dev-python = import ./modules/dev/python/default.nix;
        dev-rust = import ./modules/dev/rust/default.nix;
        dev-r = import ./modules/dev/R/default.nix;
        dev-shell = import ./modules/dev/shell/default.nix;
        dev-tools = import ./modules/dev/tools/default.nix;

        editor = import ./modules/editor/default.nix;
        editor-neovim = import ./modules/editor/neovim/default.nix;
        editor-emacs = import ./modules/editor/emacs/default.nix;

        shell = import ./modules/shell/default.nix;

        vpn = import ./modules/vpn/default.nix;

        # Services modules
        services = {
          home-assistant = import ./modules/services/home-assistant/default.nix;
          media-server = import ./modules/services/media-server/default.nix;
          media-server-transmission = import ./modules/services/media-server/transmission/default.nix;
          media-server-jellyfin = import ./modules/services/media-server/jellyfin/default.nix;
          media-server-ripping = import ./modules/services/media-server/ripping/default.nix;
        };

        # System modules
        system = {
          common = import ./modules/system/common/common/default.nix;
          common-cachix = import ./modules/system/common/common/cachix/default.nix;
          common-secrets = import ./modules/system/common/common/secrets/default.nix;
          common-system-packages = import ./modules/system/common/common/system-packages.nix;
          common-builder = import ./modules/system/common/common/builder.nix;
          common-keys = import ./modules/system/common/common/keys.nix;
          srvos-upgrade-diff = import ./modules/system/common/common/srvos/upgrade-diff.nix;
          srvos-terminfo = import ./modules/system/common/common/srvos/terminfo.nix;
          client = import ./modules/system/common/client/default.nix;
          server = import ./modules/system/common/server/default.nix;
        };
      };

      # Module collections for reusable configuration sets
      moduleCollections = {
        base-nixos = [
          # Core system modules
          self.modules.system.common
          self.modules.system.common-cachix
          self.modules.system.common-secrets
          self.modules.system.common-builder
          self.modules.system.common-keys
          self.modules.system.common-system-packages
          self.modules.system.srvos-upgrade-diff
          self.modules.system.srvos-terminfo

          # NixOS-specific modules
          self.modules.nixos.system
          self.modules.nixos.nixos-common

          # Cross-platform modules
          self.modules.dev
          self.modules.editor
          self.modules.shell
        ];

        base-darwin = [
          # Core system modules (Darwin-compatible)
          self.modules.system.common
          self.modules.system.common-cachix
          self.modules.system.common-secrets
          self.modules.system.common-builder
          self.modules.system.common-keys
          self.modules.system.common-system-packages

          # Darwin-specific modules
          self.modules.darwin.system
          self.modules.darwin.homebrew

          # Cross-platform modules
          self.modules.dev
          self.modules.editor
          self.modules.shell
        ];

        client-home = [
          # Home-manager client modules
          self.modules.home-manager.common
          self.modules.home-manager.client
          self.modules.home-manager.client-packages
          self.modules.home-manager.client-email
        ];

        server-home = [
          # Home-manager server modules
          self.modules.home-manager.common
        ];

        nixos-client = [
          # NixOS client-specific modules
          self.modules.nixos.client
          self.modules.nixos.common-wifi
          self.modules.nixos.client-yubikey
          self.modules.nixos.common-laptop
        ];

        nixos-server = [
          # NixOS server-specific modules
          self.modules.nixos.server
          self.modules.nixos.server-laptop
          self.modules.nixos.server-secrets
        ];

        darwin-client = [
          # Darwin client-specific modules
          self.modules.darwin.dock
          self.modules.darwin.autorestic
          self.modules.home-manager.darwin
          self.modules.home-manager.darwin-packages
        ];

        development = [
          # Development environment modules
          self.modules.dev-fortran
          self.modules.dev-go
          self.modules.dev-java
          self.modules.dev-javascript
          self.modules.dev-lua
          self.modules.dev-nix
          self.modules.dev-python
          self.modules.dev-rust
          self.modules.dev-r
          self.modules.dev-shell
          self.modules.dev-tools
        ];

        editors = [
          # Editor-specific modules
          self.modules.editor-neovim
          self.modules.editor-emacs
        ];

        services = [
          # Service modules
          self.modules.services.home-assistant
          self.modules.services.media-server
          self.modules.services.media-server-transmission
          self.modules.services.media-server-jellyfin
          self.modules.services.media-server-ripping
        ];
      };

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
          mbv-desktop = {
            hostname = "mbv-desktop";
            profiles.system = {
              path = deploy-rs.lib.x86_64-linux.activate.nixos self.nixosConfigurations.mbv-desktop;
            };
          };
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

      nixosConfigurations = {
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
