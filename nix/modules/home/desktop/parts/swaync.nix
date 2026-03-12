# SwayNotificationCenter notification daemon
# NOTE: This module is disabled by default. It was moved here from the waybar
# module because notification icons were rendering blurry with the Adwaita icon theme.
# To enable: set `sysconf.desktop.swaync.enable = true;` in your host config.
# You'll also need to configure a waybar notification widget and disable mako.
{
  config,
  lib,
  ...
}:
let
  cfg = config.sysconf.desktop.swaync;
in
{
  options.sysconf.desktop.swaync = {
    enable = lib.mkEnableOption "SwayNotificationCenter notification daemon with control center";

    iconTheme = lib.mkOption {
      type = lib.types.str;
      default = "Adwaita";
      description = "Icon theme to use for notification icons. May need adjustment if icons appear blurry.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Disable mako when swaync is enabled
    sysconf.desktop.niri-services.mako = lib.mkForce false;

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

        /* Notification icon - let GTK handle sizing naturally */
        .notification-icon {
          margin-right: 12px;
        }

        .notification-icon image {
          image-rendering: crisp-edges;
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
          image-rendering: crisp-edges;
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
