{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.sysconf.desktop.noctalia;

  noctaliaWallpapers = {
    defaultWallpaper = "${config.home.homeDirectory}/background-image";
    wallpapers = { };
  };

  noctaliaUserTemplates = ''
    [config]

    [templates]

    # User-defined templates
    # Add your custom templates below
    # Example:
    # [templates.myapp]
    # input_path = "~/.config/noctalia/templates/myapp.css"
    # output_path = "~/.config/myapp/theme.css"
    # post_hook = "myapp --reload-theme"

    [templates.darkman-sync]
    input_path = "${config.home.homeDirectory}/.config/noctalia-bg-hex.in"
    output_path = "${config.home.homeDirectory}/.cache/noctalia-bg-hex"
    post_hook = 'sync-darkman'
  '';

  syncDarkman = ''
    # Read the hex value from the file Noctalia just generated
    HEX_FILE="$HOME/.cache/noctalia-bg-hex"

    if [ ! -f "$HEX_FILE" ]; then
      echo "Hex file not found"
      exit 1
    fi

    # Read file and remove potential # prefix and whitespace
    HEX=$(cat "$HEX_FILE" | tr -d '#[:space:]')

    # Extract RGB components using Bash substring expansion
    # Note the double single-quotes for Nix escaping
    R_HEX=''${HEX:0:2}
    G_HEX=''${HEX:2:2}
    B_HEX=''${HEX:4:2}

    # Convert to decimal and calculate luminance
    R=$((16#''${R_HEX}))
    G=$((16#''${G_HEX}))
    B=$((16#''${B_HEX}))

    # YIQ Luminance Formula
    YIQ=$(( (R*299 + G*587 + B*114) / 1000 ))

    if [ "$YIQ" -lt 128 ]; then
      ${pkgs.darkman}/bin/darkman set dark
    else
      ${pkgs.darkman}/bin/darkman set light
    fi
  '';

  settingsJsonPath = pkgs.replaceVars ./tmpl-settings.json {
    barMonitor = cfg.barMonitor;
  };
in
{
  options.sysconf.desktop.noctalia = {
    enable = lib.mkEnableOption "noctalia";

    barMonitor = lib.mkOption {
      type = lib.types.str;
      description = "The monitor to include the topbar on.";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      file = {
        ".config/noctalia/settings.json".source = settingsJsonPath;
        ".cache/noctalia/wallpapers.json".text = builtins.toJSON noctaliaWallpapers;
        ".config/noctalia-bg-hex.in".text = "{{colors.surface.default.hex}}";
        ".config/noctalia/user-templates.toml".text = noctaliaUserTemplates;
      };

      packages =
        with pkgs;
        [
          # fuzzel
          grim
          mako
          playerctl
          polkit_gnome
          slurp
          swappy
          swayidle
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
          (pkgs.writeShellScriptBin "sync-darkman" syncDarkman)
        ]
        ++ [ pkgs-unstable.noctalia-shell ];

      # Noctalia doesn't seem to be able to read the settings if home.file is used.
      # activation.copySettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      #   $DRY_RUN_CMD cat << EOF > "${config.home.homeDirectory}/.config/noctalia/settings.json"
      #   ${settingsJson}
      #   EOF
      #   $DRY_RUN_CMD chmod u+w "${config.home.homeDirectory}/.config/noctalia/settings.json"
      # '';
    };

    # Switching between light/dark will be managed by Noctalia. This just provides the dbus backend.
    services.darkman = {
      enable = true;
      settings = {
        usegeoclue = false;
      };
    };

    systemd.user.services = {
      noctalia-shell = {
        Unit = {
          Description = "Noctalia Shell";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
        };
        Service = {
          ExecStart = lib.getExe pkgs-unstable.noctalia-shell;
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      mako = {
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

      polkit-gnome-authentication-agent = {
        Unit = {
          Description = "Polkit authentication agent";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
        };
        Service = {
          ExecStart = "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };

      swayidle = {
        Unit = {
          Description = "Idle manager";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
        };
        Service = {
          ExecStart = "${pkgs.swayidle}/bin/swayidle -w timeout 600 'noctalia-shell ipc call lockScreen lock' before-sleep 'noctalia-shell ipc call lockScreen lock'";
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
