{
  config,
  lib,
  pkgs,
  pkgs-unstable,
  ...
}:
let
  cfg = config.sysconf.desktop.noctalia;
  niriCfg = config.sysconf.desktop.niri;
  niriConfigFile = "${config.home.homeDirectory}/.config/niri/noctalia/config.kdl";

  noctaliaWallpapers = {
    defaultWallpaper = "${config.home.homeDirectory}/Wallpapers/089.png";
    wallpapers = { };
  };

  minToSec = n: n * 60;

  # User defined templates to extend their built-in ones.
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

    # Create a file that darkman can read to determine dark/light theme.
    [templates.darkman-sync]
    input_path = "${config.home.homeDirectory}/.config/noctalia-bg-hex.in"
    output_path = "${config.home.homeDirectory}/.cache/noctalia-bg-hex"
    post_hook = 'sync-darkman'

    [templates.rofi]
    input_path = "${config.home.homeDirectory}/.config/rofi/tmpl-noctalia.rasi"
    output_path = "${config.home.homeDirectory}/.config/rofi/noctalia.rasi"
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
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"
    else
      ${pkgs.darkman}/bin/darkman set light
      ${pkgs.dconf}/bin/dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"
    fi
  '';

  # Build swayidle command based on configured timeouts
  swayidleCmd =
    let
      lockCmd = "noctalia-shell ipc call lockScreen lock";
      lockTimeout = minToSec niriCfg.lockTimeout;
      monitorOffTimeout = minToSec niriCfg.monitorOffTimeout;
      suspendTimeout = minToSec niriCfg.suspendTimeout;
      hasLockTimeout = lockTimeout > 0;
      hasMonitorTimeout = monitorOffTimeout > 0;
      hasSuspendTimeout = suspendTimeout > 0;

      # Build timeout arguments in order
      timeouts =
        (lib.optionalString hasLockTimeout "timeout ${toString lockTimeout} '${lockCmd}' ")
        + (lib.optionalString (
          hasMonitorTimeout && (!hasLockTimeout || monitorOffTimeout > lockTimeout)
        ) "timeout ${toString monitorOffTimeout} 'niri msg action power-off-monitors' ")
        + (lib.optionalString hasSuspendTimeout "timeout ${toString suspendTimeout} 'systemctl suspend' ")
        + (lib.optionalString hasMonitorTimeout "resume 'niri msg action power-on-monitors' ");

      # Build before-sleep command (always lock before sleep if lockTimeout is set)
      beforeSleep = lib.optionalString hasLockTimeout "before-sleep '${lockCmd}'";

      # When monitorOffTimeout is set but is less than or equal to lockTimeout,
      # the monitor-off timeout is skipped (Line 25-27), but the resume command
      # on Line 29 is still added. This results in a resume directive without a
      # corresponding timeout for monitor-off.

      # While swayidle handles this gracefully (the resume is simply never triggered),
      # it's unnecessary and could be confusing.
    in
    if hasLockTimeout || hasMonitorTimeout || hasSuspendTimeout then
      "${pkgs.swayidle}/bin/swayidle -w ${timeouts}${beforeSleep}"
    else
      null;

  # To find out what changes the GUI makes, run `noctalia-shell ipc call state all | jq .settings.bar.widgets.right`
  settingsJsonPath = pkgs.replaceVars ./tmpl-settings.json {
    barMonitor = cfg.barMonitor;
    facePath = "${config.home.homeDirectory}/eightbit-me.png";
  };
in
{
  options.sysconf.desktop.noctalia = {
    enable = lib.mkEnableOption "noctalia";

    barMonitor = lib.mkOption {
      type = lib.types.str;
      description = "The monitor to include the topbar on.";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      file = {
        # Noctalia's theme templating writes a file with colors to .config/niri/noctalia.kdl
        ".config/niri/noctalia/config.kdl".source = ./niri-config.kdl;
        ".cache/noctalia/wallpapers.json".text = builtins.toJSON noctaliaWallpapers;
        ".config/noctalia/settings.json".source = settingsJsonPath;
        ".config/noctalia/user-templates.toml".text = noctaliaUserTemplates;
        ".config/noctalia-bg-hex.in".text = "{{colors.surface.default.hex}}";
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
          xdg-desktop-portal-gtk
          xdg-desktop-portal-wlr
          (pkgs.writeShellScriptBin "sync-darkman" syncDarkman)
        ]
        ++ [ pkgs-unstable.noctalia-shell ]
        ++ lib.optionals (
          niriCfg.lockTimeout > 0 || niriCfg.monitorOffTimeout > 0 || niriCfg.suspendTimeout > 0
        ) [ pkgs.swayidle ];

      activation.initNoctalia = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # ensure niri noctalia config file exists
        if [[ ! -f "${niriConfigFile}" ]]; then
          mkdir -p $(dirname "${niriConfigFile}")
          touch "${niriConfigFile}"
        fi
      '';
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

      # Configure swayidle service if timeouts are set
      swayidle = lib.mkIf (swayidleCmd != null) {
        Unit = {
          Description = "Idle manager";
          PartOf = [ "graphical-session.target" ];
          After = [ "graphical-session.target" ];
          ConditionEnvironment = "XDG_CURRENT_DESKTOP=niri";
        };
        Service = {
          ExecStart = swayidleCmd;
          Restart = "on-failure";
        };
        Install = {
          WantedBy = [ "graphical-session.target" ];
        };
      };
    };
  };
}
