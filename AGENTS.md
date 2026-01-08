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
- **OpenTofu**: Infrastructure as Code (Terraform fork) for cloud resources

## Repository Structure

```
.
├── flake.nix              # Entry point defining all configurations
├── Taskfile.yml           # Task commands for common operations
├── nix/
│   ├── settings.nix       # Custom configuration options
│   ├── machines/          # Per-host configurations
│   ├── modules/           # Shared modules (replaces home/ and system/)
│   │   ├── home/          # Home Manager modules
│   │   │   ├── containers/    # Development containers
│   │   │   ├── desktop/       # Desktop environment configs
│   │   │   │   ├── cosmic/    # COSMIC DE configuration
│   │   │   │   └── gnome.nix  # GNOME DE configuration
│   │   │   ├── programs/      # User programs (all have enable options)
│   │   │   ├── services/      # User services
│   │   │   └── default.nix    # Home module aggregator
│   │   └── system/        # NixOS system modules
│   │       ├── containers/    # System containers
│   │       ├── de/            # Desktop environment system config
│   │       ├── services/      # System services
│   │       └── default.nix    # System module aggregator
│   └── templates/         # Project templates
├── infra/                 # OpenTofu/Terraform infrastructure code
│   ├── provider.tf        # Provider configurations (Cloudflare, DigitalOcean)
│   ├── cloudflare.tf      # Cloudflare zone settings and DNS
│   ├── dns.tf             # DNS records
│   ├── app.tf             # DigitalOcean App Platform resources
│   ├── vps.tf             # DigitalOcean VPS/Droplet resources
│   ├── spaces.tf          # DigitalOcean Spaces (S3-compatible storage)
│   └── variables.tf       # Input variables
├── dotfiles/              # Additional dotfiles managed with stow
├── secrets/               # Encrypted secrets (SOPS)
└── docs/                  # Documentation
```

## Module Organization

### Home Manager Modules (`nix/modules/home/`)

All Home Manager modules follow a consistent pattern with enable options:

**Module Categories:**
- **containers/**: Development containers (MongoDB, PostgreSQL)
- **desktop/**: Desktop environment configurations
  - `cosmic/`: COSMIC DE theme and settings
  - `gnome.nix`: GNOME DE configuration
- **programs/**: User applications (all have `sysconf.programs.<name>.enable` options)
  - Individual programs: bat, chromium, direnv, firefox, ghostty, git, goose, micro, opencode, rofi, tmux, vscode, zed-editor, zsh
  - Each module can be enabled/disabled independently
- **services/**: User-level systemd services

**Conditional Loading:**
- Modules are always imported but conditionally enabled based on settings
- Desktop-specific programs only enabled when `hostRole == "desktop"`
- Desktop environment configs loaded based on `desktopEnvironment` setting

### System Modules (`nix/modules/system/`)

System-level configuration modules:
- **containers/**: System containers and container runtime
- **de/**: Desktop environment system packages (cosmic, gnome)
- **services/**: System services (caddy, coredns, ntfy, jellyfin, etc.)

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
- `sysconf.settings.hostRole`: Host role - "desktop" or "server" (determines which programs/services are enabled)
- `sysconf.settings.desktopEnvironment`: Desktop environment - "cosmic", "gnome", or "none"

### Module Enable Pattern
All program modules follow this pattern:

```nix
{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.programs.<name>;
in
{
  options.sysconf.programs.<name> = {
    enable = lib.mkEnableOption "<name>";
  };

  config = lib.mkIf cfg.enable {
    # Module configuration here
  };
}
```

Modules are enabled in `nix/modules/home/default.nix` based on `hostRole`:
- Base programs (enabled for all hosts): bat, direnv, git, micro, tmux, zsh
- Desktop programs (enabled only when `hostRole == "desktop"`): chromium, firefox, ghostty, goose, opencode, rofi, vscode, zed-editor

## Best Practices for Agents

1. **Understand Context**: Always check which host configuration you're modifying by examining the file path
2. **Follow Patterns**: Use existing configuration patterns rather than creating new ones
3. **Respect Separation**: Keep system-level configs in `modules/system/` and user-level in `modules/home/`
4. **Secret Handling**: Never commit unencrypted secrets; use SOPS for sensitive data
5. **Module Organization**: New programs go in `nix/modules/home/programs/` with an enable option
6. **Testing**: Suggest building configurations with `task build -- #<host>` before deployment

## Common Tasks

### Adding a New Package
1. Determine if it's a system or user package
2. For user packages:
   - Create module in `nix/modules/home/programs/<name>.nix` with enable option
   - Add enable statement in `nix/modules/home/default.nix`
   - Consider whether it should be desktop-only or available for all hosts
3. For system packages:
   - Add to appropriate file in `nix/modules/system/`

### Adding a New Program Module
1. Create file in `nix/modules/home/programs/<name>.nix`
2. Follow the module enable pattern (see "Module Enable Pattern" above)
3. Add import in `nix/modules/home/programs/default.nix` if not auto-imported
4. Enable in `nix/modules/home/default.nix`:
   - Base section for all hosts
   - Desktop section if desktop-only

### Modifying Services
1. Services are defined in `nix/modules/system/services/` or `nix/modules/home/services/`
2. Follow existing patterns for service definitions

### Working with Secrets
1. Encrypted files end with `-enc` suffix
2. Use `sops` command to edit, never edit encrypted content directly
3. Keys are defined in `.sops.yaml`

### Testing Host Configurations
1. Use `task build -- #<host>` to check the build for a specific host
2. Use `task clean` after running builds

### Adding New Nix Files
1. When adding new nix files, they must be added to git before `task build` or any `nix` command will run properly. This applies only to new nix files, existing files do not need to be added. Do not run `git add` for existing files or `git commit` until the code is working and tested.

### Working with Infrastructure (OpenTofu)
1. **This project uses OpenTofu, not Terraform**. Always use `tofu` commands, not `terraform` commands.
2. Infrastructure code is in the `infra/` directory
3. Common commands:
   ```bash
   cd infra
   tofu init      # Initialize providers
   tofu plan      # Preview changes
   tofu apply     # Apply changes
   tofu state     # Manage state (e.g., state rm, state mv for migrations)
   ```
4. **Provider versions**: This project uses Cloudflare provider v5+ which has breaking changes from v4:
   - `cloudflare_zone_settings_override` was removed, use individual `cloudflare_zone_setting` resources
   - Each zone setting (ssl, tls_1_3, etc.) is now a separate resource with `setting_id` and `value` attributes
5. **State management**: When resources are renamed or replaced, use state commands to avoid destroying and recreating:
   ```bash
   tofu state rm <old_resource>              # Remove old resource from state
   tofu import <new_resource> <resource_id>  # Import existing resource with new name
   # OR
   tofu state mv <old_resource> <new_resource>  # Move state between resource names
   ```

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
