{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.pocketid-backup;
  pocketidService = config.services.pocket-id;
in
{
  options.sysconf.services.pocketid-backup = {
    enable = lib.mkEnableOption "pocketid-backup";

    backupDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/backups/pocketid";
      description = "Directory to store temporary backup files.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Ensure backup directory exists with correct permissions
    # Owned by pocket-id so it can write if needed, but root can still read/write for borg
    systemd.tmpfiles.rules = [
      "d ${cfg.backupDir} 0755 pocket-id pocket-id -"
    ];

    systemd.services.pocketid-backup = {
      description = "PocketID database and data backup";
      unitConfig = {
        OnFailure = "notify@%i.service";
      };

      serviceConfig = {
        Type = "oneshot";
        # Run as root to have permission to stop/start pocket-id service
        User = "root";
        Group = "root";
      };

      path = with pkgs; [
        gnutar
        gzip
        sudo
      ];

      script = ''
        set -e

        BACKUP_DIR="${cfg.backupDir}"
        POCKETID_DATA_DIR="${pocketidService.dataDir}"
        POCKETID_STOPPED=false

        # Ensure PocketID is restarted on exit, even if script fails
        cleanup() {
          if [ "$POCKETID_STOPPED" = true ]; then
            echo "Ensuring PocketID service is restarted..."
            if systemctl start pocket-id.service; then
              echo "PocketID service restarted successfully"
            else
              echo "ERROR: Failed to restart PocketID service!" >&2
              exit 1
            fi
          fi
        }
        trap cleanup EXIT

        echo "Starting PocketID backup..."

        # Stop pocket-id service for consistent backup
        echo "Stopping PocketID service..."
        systemctl stop pocket-id.service
        POCKETID_STOPPED=true

        # Create tar archive of PocketID data
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        TAR_FILE="$BACKUP_DIR/pocketid-data-$TIMESTAMP.tar.gz"
        echo "Creating tar archive: $TAR_FILE"
        cd "$POCKETID_DATA_DIR"
        tar czf "$TAR_FILE" .

        # Restart pocket-id service
        echo "Restarting PocketID service..."
        systemctl start pocket-id.service
        POCKETID_STOPPED=false

        # Copy tar to ZFS backup location
        echo "Copying tar to ZFS backup..."
        mkdir -p /mnt/backup/services/pocketid
        cp "$TAR_FILE" /mnt/backup/services/pocketid/

        # Clean up old files in ZFS backup (keep last 7 days)
        find /mnt/backup/services/pocketid -name "pocketid-data-*.tar.gz" -mtime +6 -delete

        # Clean up old tar files (keep last 3 days locally)
        find "$BACKUP_DIR" -name "pocketid-data-*.tar.gz" -mtime +2 -delete

        echo "PocketID backup completed successfully"
      '';
    };

    # Timer for automatic backups
    systemd.timers.pocketid-backup = {
      description = "PocketID backup timer";
      wantedBy = [ "timers.target" ];
      timerConfig = {
        OnCalendar = "daily";
        Persistent = true;
        RandomizedDelaySec = "1h";
      };
    };
  };
}
