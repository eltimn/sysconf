{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.rofi;

  rofi-cliphist = pkgs.writeShellScriptBin "rofi-cliphist" ''
    # Theme detection: check Noctalia, then Cosmic
    COSMIC_THEME_FILE="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"
    NOCTALIA_THEME_FILE="$HOME/.config/rofi/noctalia.rasi"

    if [[ -f "$NOCTALIA_THEME_FILE" ]]; then
      THEME="noctalia"
    elif [[ -f "$COSMIC_THEME_FILE" ]]; then
      if [[ "$(cat "$COSMIC_THEME_FILE")" == "true" ]]; then
        THEME="dark"
      else
        THEME="light"
      fi
    else
      # Default to light for non-COSMIC/Noctalia sessions
      THEME="light"
    fi

    cliphist list | rofi -dmenu -theme "$HOME/.config/rofi/$THEME.rasi" -p "Clipboard" | cliphist decode | wl-copy
  '';
in
{
  options.sysconf.programs.rofi = {
    enable = lib.mkEnableOption "rofi";
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
      # Symlink themes to ~/.config/rofi
      file = {
        ".config/rofi/dark.rasi".source = ./themes/dark.rasi;
        ".config/rofi/light.rasi".source = ./themes/light.rasi;
        ".config/rofi/tmpl-noctalia.rasi".source = ./tmpl-noctalia.rasi;
      };

      packages = with pkgs; [
        cliphist
        rofi-cliphist
        wl-clipboard
      ];
    };

    programs.rofi = {
      enable = true;
      package = pkgs.rofi; # Includes Wayland support as of nixpkgs 25.11
    };
  };
}
