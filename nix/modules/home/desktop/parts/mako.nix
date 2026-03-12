# Mako notification daemon with Tokyo Night theming
# Supports automatic dark/light theme switching via darkman
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.mako;

  # Tokyo Night Dark colors for mako
  darkConfig = pkgs.writeText "mako-dark-config" ''
    # Tokyo Night Dark theme
    background-color=#1a1b26
    text-color=#c0caf5
    border-color=#7aa2f7
    border-size=2
    border-radius=8
    padding=12
    margin=12
    font=monospace 10
    default-timeout=5000
    anchor=top-right
  '';

  # Tokyo Night Light colors for mako
  lightConfig = pkgs.writeText "mako-light-config" ''
    # Tokyo Night Light theme
    background-color=#e1e2e7
    text-color=#3760bf
    border-color=#2e7de9
    border-size=2
    border-radius=8
    padding=12
    margin=12
    font=monospace 10
    default-timeout=5000
    anchor=top-right
  '';

  # Script to sync mako theme with darkman
  syncThemeScript = pkgs.writeShellScriptBin "sync-mako-theme" ''
    THEME_MODE="$1"

    if [[ "$THEME_MODE" != "dark" && "$THEME_MODE" != "light" ]]; then
      echo "Invalid theme mode: $THEME_MODE"
      exit 1
    fi

    MAKO_CONFIG_DIR="${config.xdg.configHome}/mako"
    mkdir -p "$MAKO_CONFIG_DIR"

    if [[ "$THEME_MODE" == "dark" ]]; then
      cat ${cfg.darkConfig} > "$MAKO_CONFIG_DIR/config"
    else
      cat ${cfg.lightConfig} > "$MAKO_CONFIG_DIR/config"
    fi

    # Reload mako if running
    ${pkgs.mako}/bin/makoctl reload 2>/dev/null || true
  '';
in
{
  options.sysconf.desktop.mako = {
    enable = lib.mkEnableOption "mako notification daemon.";

    darkConfigFile = lib.mkOption {
      type = lib.types.path;
      default = darkConfig;
      description = "Path to the dark theme config file for mako.";
    };

    lightConfigFile = lib.mkOption {
      type = lib.types.path;
      default = lightConfig;
      description = "Path to the light theme config file for mako.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ syncThemeScript ];

    # Register theme handler with darkman if enabled
    sysconf.desktop.themeHandlers.mako = syncThemeScript;

    # Initialize mako config with current theme on activation
    home.activation.makoThemeInit = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD ${pkgs.bash}/bin/bash -c '
        THEME_MODE=$(${lib.getExe pkgs.darkman} get 2>/dev/null || echo "dark")
        ${lib.getExe syncThemeScript} "$THEME_MODE"
      '
    '';

    # Mako notification daemon systemd service
    systemd.user.services.mako = {
      Unit = {
        Description = "Mako notifications";
        PartOf = [ "graphical-session.target" ];
        After = [ "graphical-session.target" ];
        ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
      };
      Service = {
        ExecStart = lib.getExe pkgs.mako;
        Restart = "on-failure";
      };
      Install = {
        WantedBy = [ "graphical-session.target" ];
      };
    };
  };
}
