{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.niri;
  noctaliaConfigFile = "${config.home.homeDirectory}/.config/niri/noctalia.kdl";

  # Build swayidle command based on configured timeouts
  swayidleCmd =
    let
      lockCmd = "noctalia-shell ipc call lockScreen lock";
      lockTimeout = cfg.lockTimeout;
      monitorOffTimeout = cfg.monitorOffTimeout;
      suspendTimeout = cfg.suspendTimeout;
      hasLockTimeout = lockTimeout != null && lockTimeout > 0;
      hasMonitorTimeout = monitorOffTimeout != null && monitorOffTimeout > 0;
      hasSuspendTimeout = suspendTimeout != null && suspendTimeout > 0;

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
    in
    if hasLockTimeout || hasMonitorTimeout || hasSuspendTimeout then
      "${pkgs.swayidle}/bin/swayidle -w ${timeouts}${beforeSleep}"
    else
      null;
in
{
  options.sysconf.desktop.niri = {
    enable = lib.mkEnableOption "niri";

    lockTimeout = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = "Timeout in seconds before locking the screen. If null, screen locking is disabled.";
    };

    monitorOffTimeout = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = "Timeout in seconds before turning off monitors. If null, monitor power-off is disabled.";
    };

    suspendTimeout = lib.mkOption {
      type = lib.types.nullOr lib.types.ints.positive;
      default = null;
      description = ''
        Timeout in seconds before suspending the system.

        Suspend (sleep) saves your session to RAM and enters a low-power state.
        The system wakes quickly but continues to use some battery power.

        Note: Hibernate (not implemented here) saves to disk and powers off completely,
        using no battery but taking longer to resume. Hibernate requires swap space
        configuration at the system level.

        If null, automatic suspend is disabled.
      '';
    };

    extraConfig = lib.mkOption {
      type = lib.types.str;
      description = "Extra config to add to Niri";
      default = "";
    };
  };

  config = lib.mkIf cfg.enable {
    home = {
      packages =
        with pkgs;
        [
          niri
          foot
          wl-clipboard
          xwayland-satellite
        ]
        ++ lib.optionals (
          cfg.lockTimeout != null || cfg.monitorOffTimeout != null || cfg.suspendTimeout != null
        ) [ pkgs.swayidle ];

      pointerCursor = {
        package = pkgs.adwaita-icon-theme;
        name = "Adwaita";
        size = 24;
        gtk.enable = true;
        x11.enable = true;
      };

      file = {
        ".config/niri/binds.kdl".source = ./files/binds.kdl;
        ".config/niri/config.kdl".source = ./files/config.kdl;
        ".config/niri/main.kdl".source = ./files/main.kdl;
        ".config/niri/extra.kdl".text = cfg.extraConfig;
      };

      activation.initNiri = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        # ensure noctalia config file exists
        if [[ ! -f "${noctaliaConfigFile}" ]]; then
          mkdir -p $(dirname "${noctaliaConfigFile}")
          touch "${noctaliaConfigFile}"
        fi
      '';
    };

    # Configure swayidle service if timeouts are set
    systemd.user.services.swayidle = lib.mkIf (swayidleCmd != null) {
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
}

# niri regex: https://docs.rs/regex/latest/regex/#syntax
