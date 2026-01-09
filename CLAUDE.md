# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Overview

This repository contains declarative NixOS and Home Manager configurations for multiple machines using Nix flakes. It manages system-level (NixOS) and user-level (Home Manager) configurations with a modular architecture.

**Managed Hosts:**
- `ruca`: Main desktop
- `lappy`: Laptop
- `cbox`: Home server
- `illmatic`: Home server/NAS
- `nixos-test-01`: Digital Ocean test VPS

**Core Technologies:**
- Nix Flakes for declarative package management
- NixOS for system configuration
- Home Manager for user environment management
- SOPS with age encryption for secrets
- Colmena for multi-host deployments
- Disko for declarative disk partitioning
- OpenTofu (not Terraform) for infrastructure

## Build and Test Commands

### Building Configurations

```bash
# Build configuration for a specific host
task build -- #ruca
task build -- #lappy

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

### Formatting and Validation

```bash
# Format Nix files (RFC 166 style)
nixfmt-rfc-style nix/modules/home/programs/example.nix

# Check for issues
nix flake check
```

### Deployment

```bash
# Colmena deployment to multiple hosts
task colmena-local-build  # Build local hive (cbox, illmatic)
task colmena-local        # Deploy to local hive
nix run .#colmena -- apply --impure --on @local
```

### Infrastructure (OpenTofu)

**IMPORTANT: This project uses OpenTofu, not Terraform.** Always use `tofu` commands.

```bash
cd infra
tofu init      # Initialize providers
tofu fmt       # Format .tf files
tofu validate  # Validate configuration
tofu plan      # Preview changes
tofu apply     # Apply changes
tofu state     # Manage state (e.g., state rm, state mv for migrations)
```

### Secret Management

```bash
sops secrets/secrets-enc.yaml    # Edit encrypted secrets
```

## Architecture

### Repository Structure

```
.
├── flake.nix              # Entry point defining all configurations
├── hive.nix               # Colmena hive configuration for deployment
├── Taskfile.yml           # Task commands for common operations
├── nix/
│   ├── machines/          # Per-host configurations
│   │   └── {host}/
│   │       ├── system.nix                # NixOS system configuration
│   │       ├── home-nelly.nix           # Home Manager user configuration
│   │       ├── hardware-configuration.nix
│   │       └── disks.nix                # Disko disk partitioning
│   ├── modules/           # Shared modules
│   │   ├── home/          # Home Manager modules
│   │   │   ├── containers/    # Development containers
│   │   │   ├── desktop/       # Desktop environment configs
│   │   │   │   ├── cosmic/    # COSMIC DE theme and settings
│   │   │   │   └── gnome.nix  # GNOME DE configuration
│   │   │   ├── programs/      # User programs (all have enable options)
│   │   │   ├── services/      # User services
│   │   │   └── default.nix    # Home module aggregator
│   │   └── system/        # NixOS system modules
│   │       ├── containers/    # System containers
│   │       ├── desktop/       # Desktop environment system config
│   │       ├── services/      # System services
│   │       ├── users/         # User management modules
│   │       ├── settings.nix   # System settings and options
│   │       ├── sops.nix       # SOPS configuration
│   │       └── default.nix    # System module aggregator
│   └── templates/         # Project templates (basic, go-basic, go-templ)
├── infra/                 # OpenTofu infrastructure code
├── secrets/               # Encrypted secrets (SOPS)
└── docs/                  # Documentation
```

### Module Organization

**Home Manager Modules (`nix/modules/home/`):**
- All modules follow a consistent pattern with `sysconf.programs.<name>.enable` options
- Modules are always imported but conditionally enabled based on `hostRole` setting
- Desktop-specific programs only enabled when `hostRole == "desktop"`
- Desktop environment configs loaded based on `desktopEnvironment` setting

**System Modules (`nix/modules/system/`):**
- `settings.nix`: Central system settings defining all `sysconf.settings.*` options
- `default.nix`: Module aggregator that imports all system modules
- Desktop environments conditionally enabled based on `desktopEnvironment` setting
- User modules in `users/` directory with enable options

### Custom Options System

**System Settings (`nix/modules/system/settings.nix`):**
- `sysconf.settings.timezone`: System timezone (default: "America/Chicago")
- `sysconf.settings.hostName`: Hostname
- `sysconf.settings.deployKeys`: SSH public keys for deployment automation
- `sysconf.settings.hostRole`: "desktop" or "server" (determines enabled programs/services)
- `sysconf.settings.desktopEnvironment`: "cosmic", "gnome", or "none"

**User Management (`nix/modules/system/users/`):**
- `sysconf.users.nelly.enable`: Enable primary user configuration
- `sysconf.users.nelly.hashedPasswordFile`: Location of hashed password file
- `sysconf.users.nelly.sshKeys`: SSH public keys for nelly user
- `sysconf.system.users.sysconf.enable`: Enable deployment user (for Colmena)

**Accessing Settings:**
- In system modules: `config.sysconf.settings.*`
- In Home Manager modules: `osConfig.sysconf.settings.*`

## Code Style and Patterns

### Standard Module Structure

```nix
{
  config,      # Module config
  lib,         # Nixpkgs lib functions
  pkgs,        # Packages (system modules) or omit if not needed
  osConfig,    # System config (Home Manager modules only)
  ...
}:
let
  cfg = config.sysconf.programs.<name>;  # Use 'cfg' for module config
  settings = osConfig.sysconf.settings;  # Use 'settings' for system settings (HM)
  # OR
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

### Formatting Standards

- **Indentation**: 2 spaces (no tabs)
- **Formatter**: Use `nixfmt-rfc-style` for consistent formatting
- **Variables**: camelCase (`cfg`, `basePkgs`, `desktopPkgs`)
- **Options**: camelCase with dots (`sysconf.programs.git.enable`)
- **Files**: kebab-case (`sshd.nix`, `git-worktree-runner.nix`)
- **Directories**: lowercase (`programs`, `services`, `desktop`)

### Conditional Configuration

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

### Type Safety

- Always specify types: `lib.types.str`, `lib.types.bool`, `lib.types.listOf`
- Use `lib.mkEnableOption` for simple boolean flags
- Use `lib.mkOption` for options with defaults or complex types
- Always include `description` for options

### Package Sources

- Use `pkgs` for stable packages from nixpkgs
- Use `pkgs-unstable` for packages from nixpkgs-unstable channel
- Both are available in all modules via overlays

## Common Workflow Patterns

### Adding a New Program Module

1. Create file in `nix/modules/home/programs/<name>.nix` following the standard module pattern
2. Add import in `nix/modules/home/programs/default.nix` if not auto-imported
3. Enable in `nix/modules/home/default.nix`:
   - Base section for all hosts
   - Desktop section if desktop-only (inside `lib.mkIf (settings.hostRole == "desktop")`)
4. **CRITICAL**: Add new .nix files to git before building: `git add <file>.nix`
5. Test with `task build -- #<host>`

### Adding a New System Service

1. Create file in `nix/modules/system/services/<name>.nix`
2. Follow existing service patterns with enable options
3. Import in `nix/modules/system/services/default.nix` if needed
4. Enable in host `system.nix` files as needed

### Modifying System Settings

1. All system settings are centralized in `nix/modules/system/settings.nix`
2. Define new options with proper types and descriptions
3. Access in system modules via `config.sysconf.settings.*`
4. Access in home modules via `osConfig.sysconf.settings.*`

### Working with Secrets

1. Encrypted files have `-enc` suffix (e.g., `secrets-enc.yaml`)
2. Edit with: `sops secrets/secrets-enc.yaml`
3. Never edit encrypted content directly
4. Keys are defined in `.sops.yaml`

### Git and New Files

**IMPORTANT**: When adding new .nix files, they must be added to git before `task build` or any `nix` command will work. This applies only to new files. Do not run `git add` for existing files or `git commit` until code is tested and working.

## Important Conventions

- The custom options namespace is "sysconf" with sub-namespaces
- Modules are always imported but conditionally enabled
- Desktop-specific configs only apply when `hostRole == "desktop"`
- Keep system configs in `modules/system/`, user configs in `modules/home/`
- Never commit unencrypted secrets; use SOPS
- Import shared modules rather than duplicating configuration
- Test builds with `task build -- #<host>` before deployment
- Use `task clean` after running builds
