# Zen Browser Configuration

This directory contains configuration files for Zen Browser managed outside of Nix/Home Manager.

## Structure

```
.zen/
├── profiles.ini    # Profile configuration
└── nelly/
    └── user.js     # User preferences applied on browser startup
```

## Usage

Run `task dotfiles` to stow the Zen Browser configuration to `~/.zen/`. This will create symlinks:
- `~/.zen/profiles.ini` → `~/sysconf/dotfiles/zen/dot-zen/profiles.ini`
- `~/.zen/nelly/user.js` → `~/sysconf/dotfiles/zen/dot-zen/nelly/user.js`

Restart Zen Browser after running `task dotfiles` for the first time.

**Note**: If you have an existing Zen Browser profile, you may need to back up `~/.zen/profiles.ini` before running `task dotfiles`.

## What's Configured

- **Basic Settings**: Disables default browser check, sets homepage to about:blank, enables vertical tabs, disables tab close warning
- **Telemetry**: Disables all Firefox/Zen telemetry and data collection
- **Privacy**: Enables tracking protection, HTTPS-only mode
- **Unwanted Features**: Disables Pocket, sponsored content, Firefox studies

## Modifying Settings

Edit `~/sysconf/dotfiles/zen/dot-zen/nelly/user.js` and restart Zen Browser. Preferences in `user.js` will override those in `prefs.js` on each startup.
