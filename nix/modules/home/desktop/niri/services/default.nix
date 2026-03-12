{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.niri-services;
  niriCfg = config.sysconf.desktop.niri;

  minToSec = n: n * 60;

  # Build swayidle command based on configured timeouts
  swayidleCmd =
    let
      lockCmd = "${pkgs.swaylock}/bin/swaylock -f -c 000000";
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
    in
    if hasLockTimeout || hasMonitorTimeout || hasSuspendTimeout then
      "${pkgs.swayidle}/bin/swayidle -w ${timeouts}${beforeSleep}"
    else
      null;
in
{
  options.sysconf.desktop.niri-services = {
    enable = lib.mkEnableOption "niri shared services";

    swayidle = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable swayidle for screen lock and power management. Respects niri lockTimeout, monitorOffTimeout, and suspendTimeout settings.";
    };

    polkitGnome = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable polkit-gnome authentication agent.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Install swayidle packages
    home.packages =
      with pkgs;
      lib.optionals cfg.swayidle [ swaylock ]
      ++ lib.optionals (
        cfg.swayidle
        && (niriCfg.lockTimeout > 0 || niriCfg.monitorOffTimeout > 0 || niriCfg.suspendTimeout > 0)
      ) [ swayidle ];

    systemd.user.services = lib.mkMerge [
      # Polkit authentication agent
      (lib.mkIf cfg.polkitGnome {
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
      })

      # Swayidle idle management
      (lib.mkIf (cfg.swayidle && swayidleCmd != null) {
        swayidle = {
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
      })
    ];
  };
}
