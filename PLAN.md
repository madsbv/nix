# Refactoring Plan: Module-Centric Nix Flake

## Architecture

**Core principle:** All modules are always imported on all systems, default-disabled.
Presets (in `presets/`) configure modules by setting enable flags and personalization.
Hosts import presets and set host-specific overrides.

```
flake.nix
  ├── outputs.nixosModules (attrset)     # All NixOS modules (reusable)
  ├── outputs.darwinModules (attrset)    # All Darwin modules (reusable)
  ├── outputs.homeManagerModules (attrset) # All HM modules (reusable)
  └── outputs.systemModules (attrset)    # Cross-platform system modules
       ↓ attrValues at usage site
  nixos-system/darwin-system → modules = [...] (list, all modules imported)

hosts/<host>/default.nix
  └── imports = [ ../presets/... ]       # Just presets + host overrides

presets/...
  └── Sets enable flags + personalization
      No module imports (all modules already in scope)
```

## Phases

### Phase 1: Fix flake.nix — make it evaluate

**1a.** Fix type errors where `genAttrs` (returns attrset) is `++` concatenated with lists. Keep module namespaces as attrsets for flake output/specialArgs; use `builtins.attrValues` when constructing the module list for system builders.

**1b.** Fix `protonvpn` — `lib.mkEnable` → `lib.mkEnableOption`

**1c.** Remove `modules/editor/neovim/` — references non-existent `config.local.hm.enable`; HM neovim module already in sharedModules

**1d.** Remove `modules/dev/` — stale/empty

### Phase 2: Rewrite hosts to import presets

Each host drops `moduleCollections` and instead imports presets by relative path. The preset list per host (from main branch analysis):

| Host | Presets | Module enables |
|------|---------|----------------|
| **mbv-workstation** | system/common, system/home-manager, system/yubikey-agenix-rekey, nixos/common, nixos/desktop, nixos/efi, nixos/awesomewm | laptop, wifi, yubikey |
| **mbv-mba** | system/common, system/home-manager, darwin/common | dock, autorestic |
| **mbv-desktop** | system/common, system/home-manager, nixos/common, nixos/desktop, nixos/efi | server.media |
| **mbv-xps13** | system/common, system/home-manager, nixos/common, nixos/efi | laptop, server.homeAssistant |
| **hp-90** | system/common, system/home-manager, nixos/common, nixos/efi | (builder disabled) |
| **ephemeral** | system/common | keys |

### Phase 3: Remove systemModules/modules specialArgs

Since all modules are always imported, remove:
- `imports = [ systemModules.X ]` from presets (modules already in scope)
- `modules` from all function headers
- Replace `modules.*` references with direct option settings

### Phase 4: Thin presets

Presets should only enable modules and set personalization/overrides — not duplicate module config. Move duplicated config from presets into their respective modules (which already have the enable flag pattern).

### Phase 5: Refactor modules/home-manager/common/client/

Split into new HM modules:
- `homeManagerModules/librewolf/` — `local.librewolf.enable`
- `homeManagerModules/ssh/` — `local.ssh.enable`
- `homeManagerModules/terminal/` — aggregator, per-terminal sub-options
- `homeManagerModules/zathura/` — `local.zathura.enable`

Then create preset `presets/home-manager/client.nix` to enable them.

### Phase 6: Normalize enable flags

- `lib.mkEnableOption` consistently everywhere
- Most modules default `false` (builder.* default `true`)
- `tailscale` → default `false`, `autorestic` → default `false`, `dock` → default `false`

### Phase 7: Clean up directory structure

- Remove `modules/editor/`, `modules/system/nixos/`, `modules/home-manager/`, `modules/dev/`
