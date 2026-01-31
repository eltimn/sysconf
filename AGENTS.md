# Agent Configuration for sysconf Codebase

This document provides guidance for AI agents working with this NixOS/Home Manager configuration repository.

## Agent Role

You are the operator's pair programmer. You help write code, but don't manage git or building the code.

## Overview

This repository contains declarative system configurations for multiple machines using Nix flake technology. It manages both system-level (NixOS) and user-level (Home Manager) configurations.

## Build, Lint, and Test Commands

### Building Configurations

Some machines are built with standard nix commands (ruca,lappy) and some are built using Colmena (cbox,illmatic). All have tasks in Taskfile.yml. See @hive.nix for details about Colmena.

```bash
# Build configuration for a specific host (ruca, lappy)
task build -- ruca

# Build colmena hosts (cbox, illmatic)
task build-hive -- tag  # Tag can be cbox, illmatic, local, dns, or digitalocean.

# Build without deploying (dry run)
nix build .#nixosConfigurations.ruca.config.system.build.toplevel

# Validate flake structure
nix flake check

# Show flake outputs
nix flake show

# Clean build artifacts
task clean
```

### Applying Configurations
```bash
task switch           # Build and apply to current host
task boot             # Set as boot default (applies on next boot)
task update           # Update flake.lock (all inputs)
```

### Linting and Formatting

The project uses `nixfmt` (version 1.2.0+), which is the official Nix formatter implementing RFC 166. Both `nixd` and `nil` LSPs use this formatter.

```bash
# Format Nix files (RFC 166 style)
nixfmt nix/modules/home/programs/example.nix

# Format all Nix files recursively (requires nixfmt-tree)
nixfmt-tree  # or: treefmt

# Note: nixfmt formats one file at a time, while nixfmt-tree (via treefmt)
# handles entire projects recursively. Use nixfmt-tree for bulk formatting
# and nixfmt for single files or editor integration.

# Lint Nix files
statix check  # General Nix code linter (catches anti-patterns)

# Check for issues
nix flake check  # Comprehensive validation
```

### Infrastructure (OpenTofu)
```bash
cd infra
tofu init      # Initialize providers (first time)
tofu fmt       # Format .tf files
tofu validate  # Validate configuration
tofu plan      # Preview changes
tofu apply     # Apply changes
```

### Secret Management
```bash
sops secrets/secrets-enc.yaml    # Edit encrypted secrets
```

### Garbage Collection
```bash
task gc           # Run both system and home garbage collection
task gc-os        # System packages only
task gc-hm        # User packages only
```

### Deployment
```bash
# Colmena deployment to multiple hosts
task colmena-local        # Deploy to local hive (cbox, illmatic)
nix run .#colmena -- apply --impure --on @local
```

## Code Style Guidelines

### Nix Module Structure

**Standard module imports (order matters):**
```nix
{
  config,      # Module config
  lib,         # Nixpkgs lib functions
  pkgs,        # Packages (system modules) or omit (if not needed)
  osConfig,    # System config (Home Manager modules only)
  ...
}:
```

**Module pattern:**
```nix
let
  cfg = config.sysconf.programs.<name>;  # Use 'cfg' for module config
  settings = osConfig.sysconf.settings;  # Use 'settings' for system settings (HM)
  settings = config.sysconf.settings;    # Use 'settings' for system settings (System)
in
{
  options.sysconf.programs.<name> = {
    enable = lib.mkEnableOption "<name>";
  };

  config = lib.mkIf cfg.enable {
    # Configuration here
  };
}
```

### Formatting and Whitespace
- **Indentation**: 2 spaces (no tabs)
- **Line endings**: LF (Unix-style)
- **Final newline**: Required
- **Trailing whitespace**: Remove
- **Max line length**: No hard limit, but keep readable (~100 chars preferred)
- Use `nixfmt` for consistent formatting (RFC 166 style, used by nixd and nil LSPs)

### Naming Conventions
- **Variables**: camelCase (`cfg`, `basePkgs`, `desktopPkgs`)
- **Options**: camelCase with dots (`sysconf.programs.git.enable`)
- **Files**: kebab-case (`sshd.nix`, `git-worktree-runner.nix`)
- **Directories**: lowercase (`programs`, `services`, `desktop`)
- **Let bindings**: Descriptive names (`cfg`, `settings`, not `c` or `s`)

### Imports and Dependencies
- **Package sources**: Use `pkgs` for stable, `pkgs-unstable` for unstable channel
- **Import order**: No strict order, but group logically (directories first)
- **Avoid duplicates**: Use `imports = [ ./dir ]` to import all in directory

### Comments
- **Inline comments**: Use `#` for brief explanations
- **Section headers**: Use comments to separate logical sections
- **Documentation**: Option descriptions go in `description` field, not comments
- **TODOs**: Acceptable but should be addressed

### Type Safety
- Always specify types for options: `lib.types.str`, `lib.types.bool`, `lib.types.listOf`
- Use `lib.mkOption` for options with defaults or complex types
- Use `lib.mkEnableOption` for simple boolean enable flags
- Provide `default` values when appropriate
- Always include `description` for options

### Conditional Configuration
- Use `lib.mkIf` for conditional config blocks
- Use `lib.mkMerge` to combine multiple conditional blocks
- Use `lib.optionals` for conditional lists
- Example:
```nix
config = lib.mkMerge [
  {
    # Always applied
  }
  (lib.mkIf (settings.hostRole == "desktop") {
    # Desktop-only config
  })
];
```

### Error Handling
- Use `lib.mkDefault` for overridable defaults
- Use `assertions` for validation (system modules)
- Provide clear `description` fields for user-facing options
- Use `default` values to avoid undefined errors

## Important Conventions

- Use `pkgs` for stable packages, `pkgs-unstable` for unstable packages
- Reference system settings in Home Manager via `osConfig.sysconf.settings.*`
- Import shared modules rather than duplicating configuration
- Maintain consistent formatting with existing code
- The namespace used for custom options is "sysconf" with sub-namespaces:
  - `sysconf.settings.*` - Global settings
  - `sysconf.programs.*` - Home Manager programs
  - `sysconf.services.*` - System services
  - `sysconf.cosmic.*` / `sysconf.gnome.*` - Desktop environments

## Adding New Nix Files

When adding new nix files, they must be added to git before `task build` or any `nix` command will run properly. This applies only to new nix files, existing files do not need to be added. Do not run `git add` for existing files or `git commit` until the code is working and tested.

## Goals
- Keep changes minimal and focused.
- Preserve existing code style and structure.
- Ask before making broad refactors.

## Behavior
- Do not invent APIs or dependencies.
- Prefer small, testable diffs.
- Call out assumptions and missing context.

## Context
- Use only files referenced in the prompt unless told otherwise.
- For large changes, propose a plan before editing.

---

For detailed information about module organization, configuration patterns, and common tasks, see [REFERENCE.md](REFERENCE.md).
