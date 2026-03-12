# Swayidle idle management for screen lock and power management in niri
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.desktop.swayidle;
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
  options.sysconf.desktop.swayidle = {
    enable = lib.mkEnableOption "swayidle for screen lock and power management";
  };

  config = lib.mkIf (cfg.enable && niriCfg.enable && swayidleCmd != null) {
    home.packages = with pkgs; [ swaylock ] ++ [ swayidle ];

    systemd.user.services.swayidle = {
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
