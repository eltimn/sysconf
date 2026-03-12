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
      # TODO: use `cosmic-settings get com.system76.CosmicTheme.Mode is_dark`
      MODE_FILE="$HOME/.config/cosmic/com.system76.CosmicTheme.Mode/v1/is_dark"

      if [[ ! -f "$MODE_FILE" ]]; then
        echo "Mode file not found, defaulting to light" >&2
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

  desktopPkgs = with pkgs; [
    bitwarden-desktop
    borgbackup
    caligula
    devbox
    # enpass
    # entr
    ffmpeg
    filen-desktop
    firefox
    gimp2
    # git-worktree-runner
    google-chrome
    # libnss3-tools
    libnotify
    lm_sensors
    # logseq
    meld
    # mongodb-compass
    # net-tools
    nixfmt-rfc-style
    nixpkgs-lint-community
    notify-osd
    nurl
    obsidian
    # sqlitebrowser
    sqlitestudio
    # vivaldi
    # vivaldi-ffmpeg-codecs
    vhs
    vlc
    # warp-terminal
    wev
    # wezterm # https://github.com/wezterm/wezterm/issues/6025
    wl-color-picker
    yubioath-flutter
    yubikey-manager
  ];
in
{
  imports = [
    ./cosmic
    ./niri
    ./parts
    ./programs
    ./shells/dms
    ./shells/noctalia
    ./shells/waybar
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

    # Scripts are passed the current theme mode as an argument (e.g. 'dark' or 'light').
    themeHandlers = lib.mkOption {
      type = lib.types.attrsOf (
        lib.types.oneOf [
          lib.types.path
          lib.types.package
          lib.types.lines
        ]
      );
      default = { };
      description = ''
        An attribute set of custom handlers for darkman. The key is the name of the handler, and the value is either an absolute path to a script or a string containing the script content.
      '';
    };
  };

  config = lib.mkMerge [
    {
      home = {
        file."background-image".source = ./lightning-wallpaper;
        file."eightbit-me.png".source = ./eightbit-me.png;
        packages = [
          (pkgs.writeShellScriptBin "get-theme-mode" getThemeMode)
        ]
        ++ desktopPkgs;
      };

      # Enable some desktop-specific modules
      sysconf.programs = {
        chromium.enable = true;
        firefox.enable = true;
        foot.enable = true;
        ghostty.enable = true;
        nixConverter.enable = true;
        opencode.enable = true;
        rofi.enable = true;
        vscode.enable = true;
        zed-editor.enable = true;
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
      };
    })
    (lib.mkIf (settings.niriShell == "waybar") {
      sysconf = {
        desktop.waybar.enable = true;
      };
    })
  ];
}
