# Agent Configuration for sysconf Codebase

This document provides guidance for AI agents working with this NixOS/Home Manager configuration repository.

## Agent Role

You are the operator's pair programmer. You help write code, but don't manage git or building the code.

## Overview

This repository contains declarative system configurations for multiple machines using Nix flake technology. It manages both system-level (NixOS) and user-level (Home Manager) configurations.

## Key Components

### Managed Hosts
- `cbox`: Home server
- `illmatic`: Home server/NAS
- `lappy`: Laptop
- `ruca`: Main desktop

### Core Technologies
- **Nix Flakes**: Declarative package management and system configuration
- **NixOS**: Linux distribution with declarative system configuration
- **Home Manager**: User environment management
- **SOPS**: Secret management with age encryption
- **Task**: Command runner for common operations
- **Disko**: Declarative disk partitioning

## Repository Structure

```
.
├── flake.nix              # Entry point defining all configurations
├── Taskfile.yml           # Task commands for common operations
├── nix/
│   ├── settings.nix       # Custom configuration options
│   ├── machines/          # Per-host configurations
│   ├── system/            # Shared system services
│   ├── home/              # Shared user configurations
│   └── templates/         # Project templates
├── dotfiles/              # Additional dotfiles managed with stow
├── secrets/               # Encrypted secrets (SOPS)
└── docs/                  # Documentation
```

## Common Operations

### Building and Deployment
```bash
task build -- #{host} # Build configuration for host
task switch           # Apply configurations to current host
task boot             # Set as boot default
task update           # Update flake inputs
```

### Secret Management
```bash
sops secrets/file-enc.yaml    # Edit encrypted files
```

### Garbage Collection
```bash
task gc           # Run both system and home garbage collection
task gc-os        # System packages only
task gc-hm        # User packages only
```

## Configuration Patterns

### Host Configuration Files
Each host has specific configuration files in `nix/machines/{host}/`:
- `settings.toml`: Host variables
- `system.nix`: NixOS system configuration
- `home.nix`: Home Manager user configuration
- `hardware-configuration.nix`: Hardware-specific settings
- `disks.nix`: Disk partitioning (Disko)

### Custom Options
The repository defines custom options in `nix/settings.nix`:
- `sysconf.settings.timezone`: System timezone
- `sysconf.settings.hostName`: Hostname
- `sysconf.settings.primaryUsername`: Admin user
- `sysconf.settings.gitEditor`: Git editor command

## Best Practices for Agents

1. **Understand Context**: Always check which host configuration you're modifying by examining the file path
2. **Follow Patterns**: Use existing configuration patterns rather than creating new ones
3. **Respect Separation**: Keep system-level configs in `system.nix` and user-level in `home.nix`
4. **Secret Handling**: Never commit unencrypted secrets; use SOPS for sensitive data
5. **Dependency Management**: Add new packages through appropriate module files, not directly in configurations
6. **Testing**: Suggest building configurations with `task build` before deployment

## Common Tasks

### Adding a New Package
1. Determine if it's a system or user package
2. Add to appropriate file in `nix/home/`, or `nix/system`.

### Modifying Services
1. Services are defined in `nix/system/services/` or `nix/home/services/`
2. Follow existing patterns for service definitions

### Working with Secrets
1. Encrypted files end with `-enc` suffix
2. Use `sops` command to edit, never edit encrypted content directly
3. Keys are defined in `.sops.yaml`

### Testing host Configurations
1. Use `task build -- #<host>` to check the build for a specific host.
2. Use `task clean` after running builds.

### Adding New Nix Files
1. When adding new nix files, they must be added to git before `task build` or any `nix` command will run properly.

## Important Conventions

- Use `pkgs` for stable packages, `pkgs-unstable` for unstable packages
- Reference system settings in Home Manager via `osConfig.sysconf.settings.*`
- Import shared modules rather than duplicating configuration
- Maintain consistent formatting with existing code
- The namespace used for custom options is "sysconf". With sub-components like "sysconf.services" and "sysconf.home.services".

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
