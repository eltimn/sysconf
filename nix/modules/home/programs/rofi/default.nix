{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.rofi;

  rofi-cliphist = pkgs.writeShellScriptBin "rofi-cliphist" ''
    ROFI_CONFIG_DIR="$HOME/.config/rofi"
    CFG_THEME="${cfg.theme}"

    if [[ "$CFG_THEME" == "system" ]]; then
      THEME=$(get-theme-mode)
    else
      THEME="$CFG_THEME"
    fi

    ROFI_THEME_FILE="$ROFI_CONFIG_DIR/$THEME.rasi"

    if [[ ! -f "$ROFI_THEME_FILE" ]]; then
      echo "Rofi theme file not found: $ROFI_THEME_FILE"
      ROFI_THEME_FILE="$ROFI_CONFIG_DIR/light.rasi"
    fi

    cliphist list | rofi -dmenu -theme "$ROFI_THEME_FILE" -p "Clipboard: " | cliphist decode | wl-copy
  '';
in
{
  options.sysconf.programs.rofi = {
    enable = lib.mkEnableOption "rofi";

    theme = lib.mkOption {
      type = lib.types.str;
      default = "system";
      description = "Rofi theme to use. If 'system', the theme will be chosen based on the current desktop enviroment's theme mode (e.g. light/dark). Otherwise, specify a specific theme (e.g. 'light' or 'dark'). ";
    };
  };

  config = lib.mkIf cfg.enable {
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

    home = {
      packages = with pkgs; [
        cliphist
        rofi-cliphist
        wl-clipboard
      ];
    };

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
  };
}
