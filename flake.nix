{
  description = "Configuration with secrets for MacOS and NixOS";
  inputs = {
    ### Nix basics ###
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    # nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
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
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";

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
              # NOTE: Because deploy-rs is also the name of an input flake, the `pkgs` is necessary here
              pkgs.deploy-rs
              git
              age-plugin-yubikey
              agenix-rekey.packages.${system}.default
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
        inherit (self) moduleCollections;
        # NEW: Namespaced module sets
        inherit (self) homeManagerModules;
        flake-root = ./.;
        nox = inputs.nox.packages.${system}.default;
        user = "mvilladsen";
        # Legacy: modules from old pattern (for modules that still reference it)
        modules = self.modules;
      };
      darwin-args = system: (common-args system) // { inherit (self) darwinModules; };
      nixos-args = system: (common-args system) // { inherit (self) nixosModules; };

      nixos-system =
        system: hostname:
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = (nixos-args system) // {
            inherit hostname;
            systemModules = self.nixosModules; # NEW: Unified system modules
            inherit (self) homeManagerModules;
          };
          modules = [ ./hosts/${hostname} ] ++ nixos-modules;
        };

      darwin-system =
        system: hostname:
        darwin.lib.darwinSystem {
          inherit system;
          specialArgs = (darwin-args system) // {
            inherit hostname;
            systemModules = self.darwinModules; # NEW: Unified system modules
            inherit (self) homeManagerModules;
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
          dev-all = import ./modules/home-manager/dev/default.nix;
          dev = {
            all = import ./modules/home-manager/dev/default.nix;
            fortran = import ./modules/home-manager/dev/fortran/default.nix;
            docker = import ./modules/home-manager/dev/docker/default.nix;
            go = import ./modules/home-manager/dev/go/default.nix;
            java = import ./modules/home-manager/dev/java/default.nix;
            javascript = import ./modules/home-manager/dev/javascript/default.nix;
            lua = import ./modules/home-manager/dev/lua/default.nix;
            nix = import ./modules/home-manager/dev/nix/default.nix;
            python = import ./modules/home-manager/dev/python/default.nix;
            rust = import ./modules/home-manager/dev/rust/default.nix;
            r = import ./modules/home-manager/dev/R/default.nix;
            shell = import ./modules/home-manager/dev/shell/default.nix;
            tools = import ./modules/home-manager/dev/tools/default.nix;
          };
        };

        # Cross-platform modules

        editor = {
          default = import ./modules/editor/default.nix;
          editor-neovim = import ./modules/editor/neovim/default.nix;
          editor-emacs = import ./modules/editor/emacs/default.nix;
        };

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
          self.nixosModules.system.common
          self.nixosModules.common
          self.nixosModules.common-wifi
          self.nixosModules.restic
          self.nixosModules.editor.default
          self.nixosModules.shell
        ];

        base-darwin = [
          # Core system modules (Darwin-compatible)
          # Keep existing modules not yet duplicated
          self.modules.system.common
          self.modules.system.common-cachix
          self.modules.system.common-secrets
          self.modules.system.common-builder
          self.modules.system.common-keys
          self.modules.system.common-system-packages
          self.modules.system.srvos-upgrade-diff
          self.modules.system.srvos-terminfo

          # Darwin-specific modules
          self.darwinModules.system
          self.darwinModules.homebrew

          # Cross-platform modules
          self.darwinModules.dev
          self.darwinModules.editor
          self.darwinModules.shell
        ];

        client-home = [
          self.homeManagerModules.common
          self.homeManagerModules.client
          self.homeManagerModules.client-packages
          self.homeManagerModules.client-email
          self.homeManagerModules.dev
          self.homeManagerModules.editor
          self.homeManagerModules.shell
        ];

        server-home = [
          self.homeManagerModules.common
        ];

        nixos-client = [
          self.nixosModules.client
          self.nixosModules.common-wifi
          self.nixosModules.client-yubikey
          self.nixosModules.common-laptop
          # self.homeManagerModules.nixos-client
          # self.homeManagerModules.nixos-common
        ];

        nixos-server = [
          self.nixosModules.server
          self.nixosModules.server-laptop
          self.nixosModules.server-secrets
          self.homeManagerModules.nixos-common
        ];

        darwin-client = [
          self.darwinModules.dock
          self.darwinModules.autorestic
          self.homeManagerModules.darwin
          self.homeManagerModules.darwin-packages
        ];

        editors = [
          self.nixosModules.editor-neovim
          self.nixosModules.editor-emacs
        ];

        services = [
          self.nixosModules.services.home-assistant
          self.nixosModules.services.media-server
          self.nixosModules.services.media-server-transmission
          self.nixosModules.services.media-server-jellyfin
          self.nixosModules.services.media-server-ripping
        ];
      };

      pathNixosModules =
        with builtins;
        nixpkgs.lib.genAttrs (attrNames (readDir ./modules/nixosModules)) (
          dir: import ./modules/nixosModules/${dir}
        );
      pathDarwinModules =
        with builtins;
        nixpkgs.lib.genAttrs (attrNames (readDir ./modules/darwinModules)) (
          dir: import ./modules/darwinModules/${dir}
        );
      pathHomeManagerModules =
        with builtins;
        nixpkgs.lib.genAttrs (attrNames (readDir ./modules/homeManagerModules)) (
          dir: import ./modules/homeManagerModules/${dir}
        );

      # NEW: Namespaced exports following Nix ecosystem conventions
      nixosModules = {
        # System modules (NixOS compatible)
        inherit (self.modules) system;
        # NixOS-specific modules
        client = self.modules.nixos.client;
        inherit (self.modules.nixos) server;
        common = import ./modules/nixos/common;
        wifi = import ./modules/nixos/wifi;
        restic = import ./modules/nixos/restic;
        laptop = import ./modules/nixos/laptop;
        server-laptop = import ./modules/nixos/server-laptop;
        yubikey = import ./modules;

        inherit (self.modules.nixos) common-laptop;
        inherit (self.modules.nixos) server-secrets;
        # Cross-platform modules duplicated here
        inherit (self.modules) editor;
        inherit (self.modules) shell;
        inherit (self.modules) vpn;
        # Services (only in nixosModules as requested)
        inherit (self.modules) services;
        services-home-assistant = self.modules.services.home-assistant;
        services-media-server = self.modules.services.media-server;
        services-media-server-transmission = self.modules.services.media-server-transmission;
        services-media-server-jellyfin = self.modules.services.media-server-jellyfin;
        services-media-server-ripping = self.modules.services.media-server-ripping;
      };

      homeManagerModules = {
        # Home-manager modules
        inherit (self.modules.home-manager) common;
        inherit (self.modules.home-manager) client;
        inherit (self.modules.home-manager) nixos-common;
        inherit (self.modules.home-manager) nixos-client;
        inherit (self.modules.home-manager) darwin;
        # Aliases for backwards compatibility
        client-packages = self.modules.home-manager.client-packages;
        client-email = self.modules.home-manager.client-email;
        # Cross-platform modules duplicated here
        inherit (self.modules.home-manager) dev;
        inherit (self.modules) editor;
        inherit (self.modules) shell;
      };

      darwinModules = {
        inherit (self.modules.darwin) system;
        inherit (self.modules.darwin) homebrew;
        inherit (self.modules.darwin) dock;
        inherit (self.modules.darwin) autorestic;
        # Cross-platform modules duplicated here
        inherit (self.modules) dev;
        inherit (self.modules) editor;
        inherit (self.modules) shell;
      };

      # devShells = forAllSystems devShell;

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
        # mbv-desktop = nixos-system "x86_64-linux" "mbv-desktop";
        # mbv-xps13 = nixos-system "x86_64-linux" "mbv-xps13";
        # hp-90 = nixos-system "x86_64-linux" "hp-90";
      };
      # // forLinuxSystems (system: {
      #   # A system configuration for ephemeral systems--either temporary VMs or for installers.
      #   # Use nixos-generators to build a VM or ISO with
      #   # `nix build .#nixosConfigurations.ephemeral.config.formats.<format>`
      #   # Supported formats: https://github.com/nix-community/nixos-generators?tab=readme-ov-file#supported-formats
      #   # Example formats: install-iso qcow-efi (for qemu vm)
      #   "ephemeral-${system}" = nixpkgs.lib.nixosSystem {
      #     inherit system;

      #     # For VMs
      #     # Specific formats can be configured with something like:
      #     # formatConfigs.vmware = { config, ... }: {
      #     #   services.openssh.enable = true;
      #     # };
      #     # nixpkgs.hostPlatform = "aarch64-darwin";
      #     specialArgs = (nixos-args system) // {
      #       inherit system;
      #       hostname = "ephemeral";
      #     };
      #     modules = [
      #       # impermanence.nixosModules.impermanence
      #       nixos-generators.nixosModules.all-formats
      #       # disko.nixosModules.disko
      #       ./hosts/ephemeral
      #     ]
      #     ++ nixos-modules;
      #   };
      # });
    };
}
