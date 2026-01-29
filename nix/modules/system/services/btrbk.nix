{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.btrbk;
in
{
  options.sysconf.services.btrbk = {
    enable = lib.mkEnableOption "btrbk";

    configFile = lib.mkOption {
      type = lib.types.str;
      description = "btrbk configuration file content.";
    };

    timerConfig = lib.mkOption {
      type = lib.types.attrs;
      default = {
        OnCalendar = "hourly";
        Persistent = true;
        RandomizedDelaySec = "5min";
      };
      description = "Timer configuration for btrbk snapshots.";
    };
  };

  config = lib.mkIf cfg.enable {
    config.sysconf.services.notify.enable = true;

    environment.systemPackages = [ pkgs.btrbk ];

    systemd.services.btrbk = {
      description = "BTRFS backup tool";
      unitConfig = {
        OnFailure = "notify@%i.service";
      };

      serviceConfig = {
        Type = "oneshot";
        User = "root";
        Group = "root";
      };

      script = ''
        set -e

        ${pkgs.btrbk}/bin/btrbk --config /etc/btrbk/btrbk.conf run
      '';
    };

    systemd.timers.btrbk = {
      description = "Timer for btrbk snapshots";
      wantedBy = [ "timers.target" ];
      timerConfig = cfg.timerConfig;
    };

    environment.etc."btrbk/btrbk.conf".text = cfg.configFile;
  };
}
