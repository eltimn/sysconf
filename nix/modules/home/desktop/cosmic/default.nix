# COSMIC Desktop Configuration
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.cosmic;
  mkRaw = config.lib.cosmic.mkRON "raw";

  # Build output config based on primaryMonitor setting
  outputConfig =
    if cfg.primaryMonitor == null then
      config.lib.cosmic.mkRON "enum" "All"
    else
      config.lib.cosmic.mkRON "enum" {
        variant = "Name";
        value = [ cfg.primaryMonitor ];
      };
in
{
  imports = [
    ./dark-theme.nix
    ./light-theme.nix
    ./terminal.nix
  ];

  options.sysconf.desktop.cosmic = {
    enable = lib.mkEnableOption "cosmic";
    # Use `cosmic-randr list` to see what's available.
    primaryMonitor = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "The primary monitor for panels and dock (e.g., 'HDMI-A-1', 'eDP-1'). Set to null for all monitors.";
      example = "HDMI-A-1";
    };
  };

  config = {
    # Enable COSMIC Desktop declarative configuration
    wayland.desktopManager.cosmic.enable = true;

    # Enable COSMIC Calculator
    programs.cosmic-ext-calculator.enable = true;

    # Theme mode configuration (auto-switch DISABLED in favor of custom systemd timer)
    wayland.desktopManager.cosmic.configFile."com.system76.CosmicTheme.Mode" = {
      version = 1;
      entries = {
        auto_switch = false;
      };
    };

    # Systemd timers for custom theme scheduling (08:00 Light / 20:00 Dark)
    systemd.user.services.cosmic-theme-dark = {
      Unit.Description = "Switch COSMIC to Dark Mode";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo true > %h/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark'";
      };
    };
    systemd.user.timers.cosmic-theme-dark = {
      Unit.Description = "Timer for COSMIC Dark Mode";
      Timer = {
        OnCalendar = "20:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };

    systemd.user.services.cosmic-theme-light = {
      Unit.Description = "Switch COSMIC to Light Mode";
      Service = {
        Type = "oneshot";
        ExecStart = "${pkgs.bash}/bin/bash -c 'echo false > %h/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark'";
      };
    };
    systemd.user.timers.cosmic-theme-light = {
      Unit.Description = "Timer for COSMIC Light Mode";
      Timer = {
        OnCalendar = "08:00";
        Persistent = true;
      };
      Install.WantedBy = [ "timers.target" ];
    };

    # Panel and Dock configuration
    wayland.desktopManager.cosmic.panels = [
      # Top Panel
      {
        name = "Panel";
        anchor = config.lib.cosmic.mkRON "enum" "Top";
        anchor_gap = true;
        autohide = config.lib.cosmic.mkRON "optional" null;
        background = config.lib.cosmic.mkRON "enum" "Dark";
        expand_to_edges = true;
        margin = 0;
        opacity = mkRaw "1.0";
        output = outputConfig;
        plugins_center = config.lib.cosmic.mkRON "optional" [
          "com.system76.CosmicAppletTime"
        ];
        plugins_wings = config.lib.cosmic.mkRON "optional" (
          config.lib.cosmic.mkRON "tuple" [
            [
              "com.system76.CosmicAppletWorkspaces"
            ]
            [
              "com.system76.CosmicAppletStatusArea"
              "com.system76.CosmicAppletTiling"
              "com.system76.CosmicAppletAudio"
              "com.system76.CosmicAppletNetwork"
              "com.system76.CosmicAppletNotifications"
              "com.system76.CosmicAppletPower"
            ]
          ]
        );
        size = config.lib.cosmic.mkRON "enum" "XS";
      }
      # Left Dock
      {
        name = "Dock";
        anchor = config.lib.cosmic.mkRON "enum" "Left";
        anchor_gap = false;
        autohide = config.lib.cosmic.mkRON "optional" null;
        background = config.lib.cosmic.mkRON "enum" "Dark";
        expand_to_edges = false;
        margin = 0;
        opacity = mkRaw "1.0";
        output = outputConfig;
        plugins_center = config.lib.cosmic.mkRON "optional" [ ];
        plugins_wings = config.lib.cosmic.mkRON "optional" (
          config.lib.cosmic.mkRON "tuple" [
            [
              "com.system76.CosmicAppList"
              "com.system76.CosmicAppletMinimize"
            ]
            [ ]
          ]
        );
        size = config.lib.cosmic.mkRON "enum" "M";
      }
    ];

    # Custom keyboard shortcuts
    wayland.desktopManager.cosmic.shortcuts = [
      {
        key = "Ctrl+Alt+H";
        action = config.lib.cosmic.mkRON "enum" {
          variant = "Spawn";
          value = [ "rofi-cliphist" ];
        };
        description = config.lib.cosmic.mkRON "optional" "Clipboard manager";
      }
    ];
  };
}
