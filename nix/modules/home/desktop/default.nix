{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  settings = osConfig.sysconf.settings;

  getThemeMode = ''
    if [[ "$XDG_CURRENT_DESKTOP" == "niri" ]]; then
      echo $(${lib.getExe pkgs.darkman} get)
    elif [[ "$XDG_CURRENT_DESKTOP" == "cosmic" ]]; then
      # This script reads the current theme mode (dark/light) for COSMIC from the config file.
      MODE_FILE="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"

      if [[ ! -f "$MODE_FILE" ]]; then
        echo "Mode file not found, defaulting to light"
        echo "light"
        exit 0
      fi

      MODE=$(cat "$MODE_FILE" | tr -d '[:space:]')

      if [[ "$MODE" == "true" ]]; then
        echo "dark"
      else
        echo "light"
      fi
    else
      echo "light"
    fi
  '';
in
{
  imports = [
    ./cosmic
    ./niri
    ./shells/dms
    ./shells/noctalia
    ./gnome.nix
  ];

  options.sysconf.desktop = {
    monitors = lib.mkOption {
      description = "System monitors.";
      type = lib.types.submodule {
        options = {
          primary = lib.mkOption {
            type = lib.types.str;
            default = "HDMI-A-1";
            description = "Primary monitor.";
          };
          secondary = lib.mkOption {
            type = lib.types.str;
            default = "";
            description = "Secondary monitor.";
          };
        };
      };
      default = { };
    };
  };

  config = lib.mkMerge [
    {
      home = {
        file."background-image".source = ./lightning-wallpaper;
        file."eightbit-me.png".source = ./eightbit-me.png;
        packages = [
          (pkgs.writeShellScriptBin "get-theme-mode" getThemeMode)
        ];
      };
    }
    (lib.mkIf (settings.desktopEnvironment == "gnome") {
      sysconf.desktop.gnome.enable = true;
    })
    (lib.mkIf (settings.desktopEnvironment == "cosmic") {
      sysconf.desktop.cosmic.enable = true;
    })
    (lib.mkIf (settings.desktopEnvironment == "niri") {
      sysconf = {
        desktop.niri.enable = true;
      };
    })
    # Multi-session: enable Home Manager config for both COSMIC and Niri
    (lib.mkIf (settings.desktopEnvironment == "cosmic+niri") {
      sysconf = {
        desktop = {
          cosmic.enable = true;
          niri.enable = true;
        };
      };
    })
    (lib.mkIf (settings.niriShell == "noctalia") {
      sysconf = {
        desktop.noctalia.enable = true;
        programs = {
          foot.theme = "themes/noctalia";
          ghostty.theme = "noctalia";
          zed-editor.theme = {
            mode = "system";
            dark = "Noctalia Dark";
            light = "Noctalia Light";
          };
          zen-browser = {
            userChrome = ''
              @import "${config.home.homeDirectory}/.cache/noctalia/zen-browser/zen-userChrome.css";
            '';
            userContent = ''
              @import "${config.home.homeDirectory}/.cache/noctalia/zen-browser/zen-userContent.css";
            '';
          };
          rofi.theme = "noctalia";
        };
      };
    })
    (lib.mkIf (settings.niriShell == "dms") {
      sysconf = {
        desktop.dms.enable = true;
        # programs = {
        #   foot.theme = "dank-colors.ini";
        #   ghostty.theme = "dankcolors";

        #   zen-browser = {
        #     userChrome = ''
        #       @import "${config.home.homeDirectory}/.config/DankMaterialShell/zen.css";
        #     '';
        #   };
        # };
      };
    })
  ];
}
