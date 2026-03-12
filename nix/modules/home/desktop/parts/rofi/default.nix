# Rofi launcher with themed application menu, window switcher, and clipboard history
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.rofi;

  getThemeFile = ''
    ROFI_CONFIG_DIR="$HOME/.config/rofi"
    CFG_THEME="${cfg.theme}"

    if [[ "$CFG_THEME" == "system" ]]; then
      THEME=$(get-theme-mode)
    else
      THEME="$CFG_THEME"
    fi

    ROFI_THEME_FILE="$ROFI_CONFIG_DIR/$THEME.rasi"

    if [[ ! -f "$ROFI_THEME_FILE" ]]; then
      echo "Rofi theme file not found: $ROFI_THEME_FILE" >&2
      ROFI_THEME_FILE="$ROFI_CONFIG_DIR/light.rasi"
    fi

    echo "$ROFI_THEME_FILE"
  '';

  rofi-cliphist = pkgs.writeShellScriptBin "rofi-cliphist" ''
    ROFI_THEME_FILE=$(${getThemeFile})
    cliphist list | rofi -dmenu -theme "$ROFI_THEME_FILE" -p "Clipboard: " | cliphist decode | wl-copy
  '';

  rofi-launcher = pkgs.writeShellScriptBin "rofi-launcher" ''
    ROFI_THEME_FILE=$(${getThemeFile})

    # Default mode is drun (application launcher)
    MODE="''${1:-drun}"

    case "$MODE" in
      drun)
        # Use -display-drun to set custom prompt text
        rofi -show drun -theme "$ROFI_THEME_FILE" -display-drun "Apps: "
        ;;
      window)
        rofi -show window -theme "$ROFI_THEME_FILE" -display-window "Windows: "
        ;;
      run)
        rofi -show run -theme "$ROFI_THEME_FILE" -display-run "Run: "
        ;;
      *)
        echo "Unknown mode: $MODE" >&2
        echo "Usage: rofi-launcher [drun|window|run]" >&2
        exit 1
        ;;
    esac
  '';

  rofi-session-control = pkgs.writeShellScriptBin "rofi-session-control" ''
    ROFI_THEME_FILE=$(${getThemeFile})

    # Define actions
    ACTIONS="Logout
    Reboot
    Shutdown
    Suspend
    Lock"

    # Show menu and get selection
    SELECTION=$(echo -e "$ACTIONS" | rofi -dmenu -theme "$ROFI_THEME_FILE" -p "Session: ")

    # Exit if nothing selected
    [ -z "$SELECTION" ] && exit 0

    # Execute action
    case "$SELECTION" in
      "Logout")
        ${cfg.logoutCmd}
        ;;
      "Reboot")
        systemctl reboot
        ;;
      "Shutdown")
        systemctl poweroff
        ;;
      "Suspend")
        systemctl suspend
        ;;
      "Lock")
        ${cfg.lockCmd}
        ;;
      *)
        echo "Unknown action: $SELECTION" >&2
        exit 1
        ;;
    esac
  '';

  enableRofi = cfg.enableClipboardHistory || cfg.enableAppLauncher || cfg.enableSessionControl;
in
{
  options.sysconf.desktop.rofi = {
    enableClipboardHistory = lib.mkEnableOption "clipboard history with cliphist and wl-clipboard";
    enableAppLauncher = lib.mkEnableOption "application launcher menu (drun mode)";
    enableSessionControl = lib.mkEnableOption "session control menu (logout, reboot, shutdown, etc.)";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "system";
      description = "Rofi theme to use. If 'system', the theme will be chosen based on the current desktop environment's theme mode (e.g. light/dark). Otherwise, specify a specific theme name.";
    };

    lockCmd = lib.mkOption {
      type = lib.types.str;
      default = "swaylock -f -c 000000";
      description = "Command to execute for locking the screen. The default is a simple swaylock invocation with a transparent background.";
    };

    logoutCmd = lib.mkOption {
      type = lib.types.str;
      default = "niri msg action quit";
      description = "Command to execute for logging out. The default sends a quit message to Niri, which should trigger the logout process in most setups.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf enableRofi {
      # Symlink themes to ~/.config/rofi
      xdg.configFile = {
        "rofi/dark.rasi".source = ./themes/dark.rasi;
        "rofi/light.rasi".source = ./themes/light.rasi;
        "rofi/tmpl-noctalia.rasi".source = ./tmpl-noctalia.rasi; # for noctalia
      };

      programs.rofi = {
        enable = true;
        package = pkgs.rofi; # Includes Wayland support as of nixpkgs 25.11
      };
    })

    (lib.mkIf cfg.enableClipboardHistory {
      # Systemd service to watch clipboard and store in cliphist
      systemd.user.services.cliphist = {
        Unit = {
          Description = "Clipboard history watcher";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
        };
        Service = {
          ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste --type text --watch ${pkgs.cliphist}/bin/cliphist store";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      home.packages = with pkgs; [
        cliphist
        rofi-cliphist
        wl-clipboard
      ];
    })

    (lib.mkIf cfg.enableAppLauncher {
      home.packages = [ rofi-launcher ];
    })

    (lib.mkIf cfg.enableSessionControl {
      home.packages = [ rofi-session-control ];
    })
  ];
}
