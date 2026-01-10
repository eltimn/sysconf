# sysconf Reference Documentation

This document provides detailed reference information about the sysconf repository structure, module organization, and common tasks.

## Managed Hosts
- `cbox`: Home server
- `illmatic`: Home server/NAS
- `lappy`: Laptop
- `ruca`: Main desktop

## Core Technologies
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
├── hive.nix               # Colmena hive configuration for deployment
├── Taskfile.yml           # Task commands for common operations
├── nix/
│   ├── machines/          # Per-host configurations
│   ├── modules/           # Shared modules (replaces home/ and system/)
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
│   │       ├── users/          # User management modules
│   │       │   ├── nelly.nix   # Primary user configuration
│   │       │   ├── sysconf.nix # Deployment user configuration
│   │       │   └── default.nix # User modules aggregator
│   │       ├── settings.nix   # System settings and options
│   │       ├── sops.nix       # SOPS configuration
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

System-level configuration modules with a consistent structure:

**Module Files:**
- **settings.nix**: Central system settings and options (consolidated from nix/settings.nix)
  - Defines all `sysconf.settings.*` options
  - Common system configuration (timezone, networking, nix settings, locale)
- **default.nix**: Module aggregator
  - Imports all system modules including settings
  - Base system packages
  - Conditional desktop environment loading based on `desktopEnvironment` setting

**Module Categories:**
- **containers/**: System containers and container runtime (rootless, nginx, channels-dvr)
- **desktop/**: Desktop environment system packages
  - `cosmic.nix`: COSMIC DE system packages and configuration
  - `gnome.nix`: GNOME DE system packages and configuration
  - Both have enable options: `sysconf.desktop.cosmic.enable` and `sysconf.desktop.gnome.enable`
- **services/**: System services (caddy, coredns, ntfy, jellyfin, blocky, vaultwarden, sshd)
  - `sshd.nix`: SSH daemon configuration (`sysconf.services.sshd.enable`)
    - Automatically enabled for servers (when `hostRole == "server"`)
    - Disables root login and password authentication
    - Opens firewall port automatically
- **users/**: User management modules with enable options
  - `nelly.nix`: Primary user configuration (`sysconf.users.nelly.enable`)
  - `sysconf.nix`: Deployment user configuration for Colmena (`sysconf.system.users.sysconf.enable`)

**Conditional Loading:**
- Desktop environments conditionally enabled in `system/default.nix` based on `desktopEnvironment` setting
- Settings accessible throughout the system via `config.sysconf.settings.*`
- Home Manager modules access system settings via `osConfig.sysconf.settings.*`

## Configuration Patterns

### Host Configuration Files
Each host has specific configuration files in `nix/machines/{host}/`:
- `system.nix`: NixOS system configuration
- `home.nix`: Home Manager user configuration
- `hardware-configuration.nix`: Hardware-specific settings
- `disks.nix`: Disk partitioning (Disko)

### Custom Options
The repository defines custom options in `nix/modules/system/settings.nix` and `nix/modules/system/users/`:

**System Settings (`nix/modules/system/settings.nix`):**
- `sysconf.settings.timezone`: System timezone
- `sysconf.settings.hostName`: Hostname
- `sysconf.settings.deployKeys`: SSH public keys for deployment automation (CI/CD)
- `sysconf.settings.hostRole`: Host role - "desktop" or "server" (determines which programs/services are enabled)
- `sysconf.settings.desktopEnvironment`: Desktop environment - "cosmic", "gnome", or "none"
- `sysconf.settings.borgRepo`: Borg backup repo URL.
- `sysconf.settings.homeDomain`: Domain used for the home network.

**User Management Options (`nix/modules/system/users/`):**
- `sysconf.users.nelly.enable`: Enable primary user configuration
- `sysconf.users.nelly.hashedPasswordFile`: Location of hashed password file for nelly user
- `sysconf.users.nelly.sshKeys`: SSH public keys for nelly user (defaults to known keys)
- `sysconf.system.users.sysconf.enable`: Enable deployment user configuration (for Colmena)

### Module Enable Pattern
All program/service/user modules follow this consistent pattern:

- Modules are enabled in `nix/modules/home/default.nix` based on `hostRole`:
  - Base programs (enabled for all hosts): bat, direnv, git, micro, tmux, zsh
  - Desktop programs (enabled only when `hostRole == "desktop"`): chromium, firefox, ghostty, goose, opencode, rofi, vscode, zed-editor

- Users are enabled in individual host `system.nix` files via `sysconf.users.<username>.enable`

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
1. System services are defined in `nix/modules/system/services/`
2. Home services are defined in `nix/modules/home/services/`
3. Follow existing patterns for service definitions

### Modifying System Settings
1. All system settings are centralized in `nix/modules/system/settings.nix`
2. Settings are automatically loaded via `nix/modules/system/default.nix`
3. Access settings in system modules via `config.sysconf.settings.*`
4. Access settings in home modules via `osConfig.sysconf.settings.*`

### Managing Users
1. User configurations are modularized in `nix/modules/system/users/`
2. Each user module has an enable option following the established pattern
3. User modules are imported via `nix/modules/system/users/default.nix`
4. Enable users in individual host `system.nix` files via `sysconf.users.<username>.enable`
5. The sysconf user is used for Colmena deployments and has passwordless sudo access

### Working with Secrets
1. Encrypted files end with `-enc` suffix
2. Use `sops` command to edit, never edit encrypted content directly
3. Keys are defined in `.sops.yaml`

### Testing Host Configurations
1. Use `task build -- #<host>` to check the build for a specific host
2. Use `task clean` after running builds

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
