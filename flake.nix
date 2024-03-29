{
  description = "Starter Configuration with secrets for MacOS and NixOS";
  inputs = {
    ### Nix basics ###
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    # Local copy of fork of nixpkgs for development/testing package upgrades
    #nixpkgs.url = "github:madsbv/nixpkgs/emacs-no-titlebar-patch";
    # nixpkgs.url = "git+file:///Users/mvilladsen/workspace/github.com/madsbv/nixpkgs/";
    # Secrets management
    agenix = {
      url = "github:ryantm/agenix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
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
    secrets = {
      url = "git+ssh://git@github.com/madsbv/nix-secrets.git";
      flake = false;
    };
    my-doomemacs-config = {
      url = "git+ssh://git@github.com/madsbv/doom.d.git";
      flake = false;
    };
  };
  outputs = { self, darwin, nix-homebrew, homebrew-bundle, homebrew-core
    , homebrew-cask, homebrew-cask-fonts, homebrew-services, felixkratz-formulae
    , pirj-noclamshell, home-manager, nixpkgs, disko, agenix, secrets
    , my-doomemacs-config, doomemacs, fenix, ... }@inputs:
    let
      user = "mvilladsen";
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
      devShell = system:
        let pkgs = nixpkgs.legacyPackages.${system};
        in {
          default = with pkgs;
            mkShell {
              nativeBuildInputs = with pkgs; [
                bashInteractive
                git
                age
                age-plugin-yubikey
              ];
              shellHook = with pkgs; ''
                export EDITOR=${neovim}/bin/nvim
              '';
            };
        };
      mkApp = scriptName: system: {
        type = "app";
        program = "${
            (nixpkgs.legacyPackages.${system}.writeScriptBin scriptName ''
              #!/usr/bin/env bash
              PATH=${nixpkgs.legacyPackages.${system}.git}/bin:$PATH
              echo "Running ${scriptName} for ${system}"
              exec ${self}/apps/${system}/${scriptName}
            '')
          }/bin/${scriptName}";
      };
      mkLinuxApps = system: {
        "apply" = mkApp "apply" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
        "install" = mkApp "install" system;
        "install-with-secrets" = mkApp "install-with-secrets" system;
      };
      mkDarwinApps = system: {
        "apply" = mkApp "apply" system;
        "build" = mkApp "build" system;
        "build-switch" = mkApp "build-switch" system;
        "copy-keys" = mkApp "copy-keys" system;
        "create-keys" = mkApp "create-keys" system;
        "check-keys" = mkApp "check-keys" system;
      };
    in {
      devShells = forAllSystems devShell;
      apps = nixpkgs.lib.genAttrs linuxSystems mkLinuxApps
        // nixpkgs.lib.genAttrs darwinSystems mkDarwinApps;

      darwinConfigurations.macos = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = inputs // {
          inherit user color-scheme;
          flake-inputs = inputs;
        };
        modules = [
          ./hosts/darwin
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            nix-homebrew = {
              enable = true;
              user = "${user}";
              taps = {
                "homebrew/homebrew-core" = homebrew-core;
                "homebrew/homebrew-cask" = homebrew-cask;
                "homebrew/homebrew-bundle" = homebrew-bundle;
                "homebrew/homebrew-cask-fonts" = homebrew-cask-fonts;
                "homebrew/homebrew-services" = homebrew-services;
                # "koekeishiya/homebrew-formulae" = koekeishiya-formulae;
                "felixkratz/homebrew-formulae" = felixkratz-formulae;
                "pirj/homebrew-noclamshell" = pirj-noclamshell;
              };
              mutableTaps = false;
              autoMigrate = true;
            };
          }

          # TODO: Move this
          # The nixOS module doesn't seem to use anything nixOS specific, and in fact the home manager module is identical, so this should work just fine for nix-darwin too
          inputs.base16.nixosModule
          { scheme = color-scheme; }
        ];
      };

      ## NOTE: Commented out to avoid spurious errors from `nix flake check` until we actually start using NixOS
      # nixosConfigurations = nixpkgs.lib.genAttrs linuxSystems (system:
      #   nixpkgs.lib.nixosSystem {
      #     inherit system;
      #     specialArgs = inputs // { inherit user; flake-inputs = inputs; };
      #     modules = [
      #       disko.nixosModules.disko
      #       home-manager.nixosModules.home-manager
      #       ./hosts/nixos
      #     ];
      #   });
    };
}
