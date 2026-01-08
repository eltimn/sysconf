# Reorganize nix/home and nix/system into nix/modules

**Date:** 2026-01-07  
**Status:** Approved

## Overview

Consolidate `nix/home/` and `nix/system/` directories into a unified `nix/modules/` directory structure to improve repository organization and align with common Nix repository patterns.

## Current State

The repository currently has:
- `nix/home/` - Contains all Home Manager modules (user-level configurations)
- `nix/system/` - Contains all NixOS system modules (system-level configurations)
- `nix/modules/` - Empty directory that already exists

## Proposed Structure

```
nix/modules/
  home/
    common/
    containers/
    cosmic/
    desktop/
    programs/
    services/
    default.nix
    gnome.nix
  system/
    containers/
    de/
    services/
    default.nix
    rocm.nix
    sops.nix
    sysconf-user.nix
```

## Changes Required

### 1. Directory Structure
- Move `nix/home/` → `nix/modules/home/`
- Move `nix/system/` → `nix/modules/system/`

### 2. flake.nix Update
Update line 132:
```nix
# Before
./nix/system/default.nix

# After
./nix/modules/system/default.nix
```

### 3. Machine Configuration Updates

Update import paths in all machine-specific configuration files (10 files total):

**Home configurations (5 files):**
- `nix/machines/ruca/home.nix` - 11 imports
- `nix/machines/cbox/home.nix` - 6 imports
- `nix/machines/illmatic/home.nix` - 7 imports
- `nix/machines/lappy/home.nix` - 9 imports
- `nix/machines/nixos-test/home-nelly.nix` - 5 imports

**System configurations (5 files):**
- `nix/machines/ruca/system.nix` - 2 imports
- `nix/machines/cbox/system.nix` - 1 import
- `nix/machines/illmatic/system.nix` - 3 imports
- `nix/machines/lappy/system.nix` - 1 import
- `nix/machines/nixos-test/configuration.nix` - 4 imports

All paths change from:
- `../../home/*` → `../../modules/home/*`
- `../../system/*` → `../../modules/system/*`

**Total: ~49 import path updates**

## Testing Strategy

1. After moving directories and updating paths, add new files to git (required for Nix to recognize them)
2. Test build for one host: `task build -- #ruca`
3. Clean up build artifacts: `task clean`
4. If successful, verify other hosts can build as well

## Benefits

- **Cleaner organization**: Groups all reusable modules under a single `modules/` directory
- **Clear separation**: Maintains distinction between home and system configurations
- **Standard pattern**: Aligns with common Nix repository structures
- **Future scalability**: Makes it easier to add other module categories if needed

## Implementation Notes

- This is a pure refactoring - no functional changes to configurations
- All module contents remain identical, only paths change
- Git will track the moves properly when using `git mv` commands
- Must add new nix files to git before running builds
