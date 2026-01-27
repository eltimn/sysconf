# COSMIC Desktop Configuration
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.cosmic;
  cosmicLib = config.lib.cosmic;
  mkRaw = cosmicLib.mkRON "raw";

  # Build output config based on primaryMonitor setting
  outputConfig =
    if cfg.primaryMonitor == null then
      cosmicLib.mkRON "enum" "All"
    else
      cosmicLib.mkRON "enum" {
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
    # cosmic manager options
    wayland.desktopManager.cosmic = {
      # Enable COSMIC Desktop declarative configuration
      enable = true;

      # Panel and Dock configuration
      panels = [
        # Top Panel
        {
          name = "Panel";
          anchor = cosmicLib.mkRON "enum" "Top";
          anchor_gap = true;
          autohide = cosmicLib.mkRON "optional" null;
          background = cosmicLib.mkRON "enum" "Dark";
          expand_to_edges = true;
          margin = 0;
          opacity = mkRaw "1.0";
          output = outputConfig;
          plugins_center = cosmicLib.mkRON "optional" [
            "com.system76.CosmicAppletTime"
          ];
          plugins_wings = cosmicLib.mkRON "optional" (
            cosmicLib.mkRON "tuple" [
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
          size = cosmicLib.mkRON "enum" "XS";
        }
        # Left Dock
        {
          name = "Dock";
          anchor = cosmicLib.mkRON "enum" "Left";
          anchor_gap = false;
          autohide = cosmicLib.mkRON "optional" null;
          background = cosmicLib.mkRON "enum" "Dark";
          expand_to_edges = false;
          margin = 0;
          opacity = mkRaw "1.0";
          output = outputConfig;
          plugins_center = cosmicLib.mkRON "optional" [ ];
          plugins_wings = cosmicLib.mkRON "optional" (
            cosmicLib.mkRON "tuple" [
              [
                "com.system76.CosmicAppList"
                "com.system76.CosmicAppletMinimize"
              ]
              [ ]
            ]
          );
          size = cosmicLib.mkRON "enum" "M";
        }
      ];

      # Custom keyboard shortcuts
      shortcuts = [
        {
          key = "Ctrl+Alt+H";
          action = cosmicLib.mkRON "enum" {
            variant = "Spawn";
            value = [ "rofi-cliphist" ];
          };
          description = cosmicLib.mkRON "optional" "Clipboard manager";
        }
      ];

      # Theme mode configuration (auto-switch DISABLED in favor of custom systemd timer)
      configFile."com.system76.CosmicTheme.Mode" = {
        version = 1;
        entries = {
          auto_switch = false;
        };
      };

      wallpapers = [
        {
          filter_by_theme = false;
          filter_method = cosmicLib.mkRON "enum" "Lanczos";
          output = "all";
          rotation_frequency = 600;
          sampling_method = cosmicLib.mkRON "enum" "Alphanumeric";
          scaling_mode = cosmicLib.mkRON "enum" "Zoom";
          source = cosmicLib.mkRON "enum" {
            value = [
              "${config.home.homeDirectory}/background-image"
            ];
            variant = "Path";
          };
        }
      ];
    };

    # Enable COSMIC Calculator
    programs.cosmic-ext-calculator.enable = true;

    home.packages = with pkgs; [
      cosmic-reader
    ];

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
  };
}
