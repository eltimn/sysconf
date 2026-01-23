{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.forgejo-backup;
  forgejoService = config.services.forgejo;
in
{
  options.sysconf.services.forgejo-backup = {
    enable = lib.mkEnableOption "forgejo-backup";

    backupDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/backups/forgejo";
      description = "Directory to store temporary backup files.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure backup directory exists with correct permissions
    # Owned by forgejo so dump can write, but root can still read/write for borg
    systemd.tmpfiles.rules = [
      "d ${cfg.backupDir} 0755 forgejo forgejo -"
    ];

    systemd.services.forgejo-backup = {
      description = "Forgejo database and data backup";
      unitConfig = {
        OnFailure = "notify@%i.service";
      };

      serviceConfig = {
        Type = "oneshot";
        # Run as root to have permission to stop/start forgejo service
        User = "root";
        Group = "root";
      };

      path = with pkgs; [
        borgbackup
        forgejoService.package
        sudo
      ];

      script = ''
        set -e

        BACKUP_DIR="${cfg.backupDir}"
        FORGEJO_WORK_DIR="${forgejoService.stateDir}"
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        DUMP_FILE="$BACKUP_DIR/forgejo-dump-$TIMESTAMP.zip"
        FORGEJO_STOPPED=false

        # Ensure Forgejo is restarted on exit, even if script fails
        cleanup() {
          if [ "$FORGEJO_STOPPED" = true ]; then
            echo "Ensuring Forgejo service is restarted..."
            if systemctl start forgejo.service; then
              echo "Forgejo service restarted successfully"
            else
              echo "ERROR: Failed to restart Forgejo service!" >&2
              exit 1
            fi
          fi
        }
        trap cleanup EXIT

        echo "Starting Forgejo backup..."

        # Stop forgejo service for consistent backup
        echo "Stopping Forgejo service..."
        systemctl stop forgejo.service
        FORGEJO_STOPPED=true

        # Use forgejo dump to create backup (run as forgejo user since it refuses to run as root)
        echo "Running forgejo dump..."
        cd "$BACKUP_DIR"
        sudo -u forgejo ${forgejoService.package}/bin/forgejo dump \
          --work-path "$FORGEJO_WORK_DIR" \
          --file "$DUMP_FILE" \
          --skip-log

        echo "Forgejo dump created: $DUMP_FILE"

        # Restart forgejo service
        echo "Restarting Forgejo service..."
        systemctl start forgejo.service
        FORGEJO_STOPPED=false

        # Copy dump to ZFS backup location
        echo "Copying dump to ZFS backup..."
        mkdir -p /mnt/backup/services/forgejo
        cp "$DUMP_FILE" /mnt/backup/services/forgejo/

        # Clean up old files in ZFS backup (keep last 7 days)
        find /mnt/backup/services/forgejo -name "forgejo-dump-*.zip" -mtime +6 -delete

        # Clean up old dump files (keep last 3 days locally)
        find "$BACKUP_DIR" -name "forgejo-dump-*.zip" -mtime +2 -delete

        echo "Forgejo backup completed successfully"
      '';
    };

    # Timer for automatic backups
    systemd.timers.forgejo-backup = {
      description = "Forgejo backup timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
  };
}
