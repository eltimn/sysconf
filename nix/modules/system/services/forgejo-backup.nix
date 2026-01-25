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
      description = "Directory to store local backup files.";
    };

    remoteBackupLocation = lib.mkOption {
      type = lib.types.str;
      description = "Remote location to sync backup files to.";
      default = "/mnt/backup/services/forgejo";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure backup directory exists with correct permissions
    # Owned by forgejo so dump can write
    systemd.tmpfiles.rules = [
      "d ${cfg.backupDir} 0750 forgejo backup -"
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
        forgejoService.package
        rsync
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

        chown forgejo:backup "$DUMP_FILE"
        chmod 640 "$DUMP_FILE"

        echo "Forgejo dump created: $DUMP_FILE"

        # Restart forgejo service
        echo "Restarting Forgejo service..."
        systemctl start forgejo.service
        FORGEJO_STOPPED=false

        # Clean up old dump files (keep last 7 days locally)
        find "$BACKUP_DIR" -name "forgejo-dump-*.zip" -mtime +6 -delete

        # Sync backups to remote location
        echo "Syncing backups to remote ..."
        rsync -ar  --delete "$BACKUP_DIR/" "${cfg.remoteBackupLocation}"

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
