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

    wallpaperPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to the wallpaper image.";
      default = "${config.home.homeDirectory}/Wallpapers/047.jpg";
    };
  };

  config = lib.mkIf cfg.enable {
    sysconf.desktop = {
      mako.enable = true;
      polkit.enable = true;
      swappy.enable = true;
      swayidle.enable = true;

      rofi = {
        enableClipboardHistory = true;
        enableAppLauncher = true;
        enableSessionControl = true;
        lockCmd = "swaylock -f --image ${cfg.wallpaperPath}";
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
        ExecStart = "${pkgs.swaybg}/bin/swaybg -i ${cfg.wallpaperPath} -m fill";
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };

  };
}
