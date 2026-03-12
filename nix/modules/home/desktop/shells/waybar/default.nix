# https://github.com/Alexays/Waybar/wiki/Configuration
{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.waybar;
  settings = osConfig.sysconf.settings;
in
{
  options.sysconf.desktop.waybar = {
    enable = lib.mkEnableOption "waybar";

    barMonitor = lib.mkOption {
      type = lib.types.str;
      description = "The monitor to display waybar on.";
      default = config.sysconf.desktop.monitors.primary;
    };

    wallpaper = lib.mkOption {
      type = lib.types.str;
      description = "Path to the wallpaper image.";
      default = "${config.home.homeDirectory}/Wallpapers/047.jpg";
    };
  };

  config = lib.mkIf cfg.enable {
    sysconf.desktop = {
      swappy.enable = true;
      # Enable shared niri services but disable mako (we use swaync instead)
      niri-services = {
        enable = true;
        mako = false; # Disable mako, we use swaync
      };
    };

    home = {
      file = {
        ".config/niri/waybar/config.kdl".source = ./niri-config.kdl;
      };

      packages = with pkgs; [
        swaybg
      ];
    };

    programs.waybar = {
      enable = true;
      systemd.enable = true;
      settings = {
        mainBar = {
          layer = "top";
          position = "top";
          output = cfg.barMonitor;
          height = 36;
          spacing = 8;

          modules-left = [
            "niri/workspaces"
            "niri/window"
          ];

          modules-center = [
            "clock"
            "mpd"
          ];

          modules-right = [
            "custom/notification"
            "keyboard-state"
            "pulseaudio"
            "network"
            "tray"
          ];

          "niri/workspaces" = {
            format = "{value}";
            on-click = "activate";
            on-scroll-up = "niri msg action focus-column-left";
            on-scroll-down = "niri msg action focus-column-right";
          };

          "niri/window" = {
            max-length = 50;
            separate-outputs = true;
          };

          "keyboard-state" = {
            numlock = false;
            capslock = true;
            format = "{name} {icon}";
            format-icons = {
              locked = "";
              unlocked = "";
            };
          };

          network = {
            format-wifi = "{essid} ({signalStrength}%)";
            format-ethernet = "{ipaddr}/{cidr}";
            format-disconnected = "Disconnected";
            tooltip-format = "{ifname} via {gwaddr}";
            tooltip-format-wifi = "{essid} ({signalStrength}%)";
            tooltip-format-ethernet = "{ifname}";
            tooltip-format-disconnected = "Disconnected";
            max-length = 50;
          };

          clock = {
            timezone = settings.timezone;
            format = "{:%I:%M %p}";
            format-alt = "{:%Y-%m-%d %I:%M %p}";
            tooltip-format = "<big>{:%Y %B}</big>\n<tt><small>{calendar}</small></tt>";
            # calendar = {
            #   mode = "year";
            #   mode-mon-col = 3;
            #   weeks-pos = "right";
            #   on-scroll = 1;
            #   format = {
            #     months = "<span color='#ffead3'><b>{}</b></span>";
            #     days = "<span color='#ecc6d9'><b>{}</b></span>";
            #     weeks = "<span color='#99ffdd'><b>W{}</b></span>";
            #     weekdays = "<span color='#ffcc66'><b>{}</b></span>";
            #     today = "<span color='#ff6699'><b><u>{}</u></b></span>";
            #   };
            # };
            actions = {
              on-click-right = "mode";
              on-scroll-up = "tz_up";
              on-scroll-down = "tz_down";
            };
          };

          tray = {
            icon-size = 20;
            spacing = 10;
          };

          # cpu = {
          #   format = "{usage}% ";
          #   tooltip = false;
          # };

          # memory = {
          #   format = "{}% ";
          # };

          # temperature = {
          #   critical-threshold = 80;
          #   format = "{temperatureF}°F {icon}";
          #   format-icons = [
          #     ""
          #     ""
          #     ""
          #   ];
          # };

          pulseaudio = {
            format = "{volume}% {icon} {format_source}";
            format-bluetooth = "{volume}% {icon} {format_source}";
            format-bluetooth-muted = " {icon} {format_source}";
            format-muted = " {format_source}";
            format-source = "{volume}% ";
            format-source-muted = "";
            format-icons = {
              headphone = "";
              hands-free = "";
              headset = "";
              phone = "";
              portable = "";
              car = "";
              default = [
                ""
                ""
                ""
              ];
            };
            on-click = "pavucontrol";
          };

          mpd = {
            format = "{stateIcon} {consumeIcon}{randomIcon}{repeatIcon}{singleIcon}{artist} - {album} - {title} ({elapsedTime:%M:%S}/{totalTime:%M:%S}) ⸨{songPosition}|{queueLength}⸩ {volume}% ";
            format-disconnected = "Disconnected ";
            format-stopped = "{consumeIcon}{randomIcon}{repeatIcon}{singleIcon}Stopped ";
            unknown-tag = "N/A";
            interval = 5;
            consume-icons = {
              on = " ";
            };
            random-icons = {
              off = "<span color=\"#f53c3c\">\uf074</span> ";
              on = " ";
            };
            repeat-icons = {
              on = " ";
            };
            single-icons = {
              on = "1 ";
            };
            state-icons = {
              paused = "";
              playing = "";
            };
            tooltip-format = "MPD (connected)";
            tooltip-format-disconnected = "MPD (disconnected)";
          };

          "custom/notification" = {
            tooltip = true;
            format = "{icon}";
            format-icons = {
              notification = "󱅫";
              none = "󰂜";
              dnd-notification = "󰂠";
              dnd-none = "󰪓";
            };
            return-type = "json";
            exec-if = "which swaync-client";
            exec = "swaync-client -swb";
            on-click = "swaync-client -t -sw";
            on-click-right = "swaync-client -d -sw";
            escape = true;
          };

        };
      };

      style = ''
        * {
          font-family: "${osConfig.sysconf.fonts.sansSerif}", "Font Awesome 6 Free";
          font-size: 15px;
          min-height: 0;
        }

        window#waybar {
          background-color: #1a1b26;
          color: #c0caf5;
          border-bottom: 2px solid #313244;
        }

        window#waybar.hidden {
          opacity: 0.2;
        }

        /* Workspaces */
        #workspaces button {
          padding: 0 10px;
          color: #c0caf5;
          background-color: transparent;
          border: none;
          border-radius: 0;
        }

        #workspaces button:hover {
          background: rgba(255, 255, 255, 0.1);
          box-shadow: inherit;
          text-shadow: inherit;
        }

        #workspaces button.focused {
          background-color: #313244;
          color: #7aa2f7;
          border-bottom: 2px solid #7aa2f7;
        }

        #workspaces button.urgent {
          background-color: #f38ba8;
          color: #1a1b26;
        }

        /* Window title */
        #window {
          padding: 0 15px;
          color: #cdd6f4;
        }

        /* Network */
        #network {
          padding: 0 10px;
          color: #7aa2f7;
        }

        #network.disconnected {
          color: #f38ba8;
        }

        /* Clock */
        #clock {
          padding: 0 15px;
          color: #fab387;
        }

        /* Tray */
        #tray {
          padding: 0 10px;
          margin-right: 5px;
        }

        #tray > .passive {
          -gtk-icon-effect: dim;
        }

        /* Notification widget */
        #custom-notification {
          padding: 0 12px;
          color: #7aa2f7;
          font-family: "NotoSansMono Nerd Font", "Symbols Nerd Font", monospace;
        }

        #custom-notification.notification {
          color: #e0af68;
        }

        #custom-notification.dnd {
          color: #bb9af7;
        }
      '';
    };

    # Add theme handler for waybar to switch between light/dark CSS
    # sysconf.desktop.themeHandlers.waybar = pkgs.writeShellScriptBin "waybar-theme-sync" ''
    #   THEME_MODE="$1"

    #   if [[ "$THEME_MODE" != "dark" && "$THEME_MODE" != "light" ]]; then
    #     echo "Invalid theme mode: $THEME_MODE"
    #     exit 1
    #   fi

    #   # Waybar will automatically reload when CSS files change
    #   # The style.css is the main file, style-dark.css and style-light.css are alternatives
    #   # We create symlinks or copy files based on the theme mode

    #   WAYBAR_CONFIG="$HOME/.config/waybar"

    #   if [[ "$THEME_MODE" == "dark" ]]; then
    #     # Use the default dark theme (already set in style.css)
    #     : # no-op, default style is dark
    #   else
    #     # Could create a light theme variant here
    #     # For now, the user can customize this
    #     : # no-op
    #   fi

    #   # Reload waybar to pick up any changes
    #   pkill -SIGUSR2 waybar || true
    # '';

    # Wallpaper service
    systemd.user.services.swaybg = {
      Unit = {
        Description = "Wallpaper setter";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
      };
      Service = {
        ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${cfg.wallpaper} -m fill";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

    # SwayNotificationCenter for notifications with control center
    services.swaync = {
      enable = true;
      settings = {
        positionX = "right";
        positionY = "top";
        control-center-positionX = "none";
        control-center-positionY = "none";
        notification-visibility = {
          example-name = {
            state = "muted";
            urgency = "Low";
          };
        };
        widgets = [
          "title"
          "dnd"
          "notifications"
        ];
        widget-config = {
          title = {
            text = "Notifications";
            clear-all-button = true;
            button-text = "Clear All";
          };
          dnd = {
            text = "Do Not Disturb";
          };
        };
      };
      style = ''
        /* Tokyo Night Dark theme for SwayNotificationCenter */
        @define-color background #1a1b26;
        @define-color background-transparent rgba(26, 27, 38, 0.95);
        @define-color foreground #c0caf5;
        @define-color primary #7aa2f7;
        @define-color secondary #bb9af7;
        @define-color error #f7768e;
        @define-color surface #24283b;
        @define-color surface-high #353d57;

        /* Main control center window - force background */
        .control-center {
          background: @background-transparent;
          border: 2px solid @primary;
          border-radius: 12px;
          padding: 16px;
        }

        .control-center > * {
          background: transparent;
        }

        /* Notification cards - explicit backgrounds */
        .notification {
          background: @surface;
          border: 1px solid @surface-high;
          border-radius: 8px;
          padding: 12px;
          margin-bottom: 8px;
        }

        .notification:hover {
          background: @surface-high;
          border-color: @primary;
        }

        /* Notification icon - proper sizing */
        .notification-icon {
          -gtk-icon-size: 48px;
          min-width: 48px;
          min-height: 48px;
          margin-right: 12px;
        }

        .notification-icon image {
          -gtk-icon-style: symbolic;
        }

        .notification-content {
          background: transparent;
        }

        .notification-content:hover {
          background: transparent;
        }

        /* On-screen notification popup window */
        .notification-window {
          background: transparent;
        }

        .notification-window .notification {
          background: @surface;
          border: 2px solid @primary;
          border-radius: 12px;
          box-shadow: 0 4px 12px rgba(0, 0, 0, 0.4);
        }

        /* Close button */
        .close-button {
          background: @error;
          color: @background;
          border-radius: 50%;
        }

        .close-button:hover {
          background: @error;
        }

        /* Title widget */
        .widget-title {
          color: @primary;
          font-size: 16px;
          font-weight: bold;
          margin-bottom: 12px;
          background: transparent;
        }

        .widget-title button {
          background: @error;
          color: @background;
          border-radius: 6px;
          padding: 4px 8px;
        }

        .widget-title button:hover {
          background: @error;
        }

        /* DND toggle */
        .widget-dnd {
          color: @foreground;
          font-size: 14px;
          margin-bottom: 12px;
          background: transparent;
        }

        .widget-dnd > switch {
          background: @surface-high;
          border-radius: 12px;
        }

        .widget-dnd > switch:hover {
          background: @surface-high;
        }

        .widget-dnd > switch:checked {
          background: @primary;
        }

        /* Empty notification placeholder */
        .notification-placeholder {
          color: @foreground;
          opacity: 0.5;
          background: transparent;
        }

        .notification-placeholder image {
          -gtk-icon-size: 64px;
          min-width: 64px;
          min-height: 64px;
          margin-bottom: 16px;
        }

        /* Scrollbar styling */
        scrollbar {
          background: transparent;
        }

        scrollbar slider {
          background: @surface-high;
          border-radius: 8px;
        }

        /* Action buttons */
        .notification-action {
          background: @surface-high;
          border-radius: 6px;
        }

        .notification-action:hover {
          background: @primary;
        }
      '';
    };
  };
}
