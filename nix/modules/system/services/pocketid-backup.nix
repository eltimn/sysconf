{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.pocketid-backup;
  pocketidService = config.services.pocket-id;
  mountVault = config.sysconf.services.mount-vault;
in
{
  options.sysconf.services.pocketid-backup = {
    enable = lib.mkEnableOption "pocketid-backup";

    backupDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/backups/pocketid";
      description = "Directory to store temporary backup files.";
    };

    remoteBackupLocation = lib.mkOption {
      type = lib.types.str;
      description = "Remote location to sync backup files to.";
      default = "${mountVault.mountDir}/services/pocketid";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable mount-vault dependency
    sysconf.services.mount-vault.enable = true;

    # Ensure backup directory exists with correct permissions
    systemd.tmpfiles.rules = [
      "d ${cfg.backupDir} 0750 pocket-id backup -"
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

      path = [
        mountVault.package
        pkgs.gnutar
        pkgs.gzip
        pkgs.rsync
        pkgs.sudo
      ];

      script = ''
        set -e

        BACKUP_DIR="${cfg.backupDir}"
        POCKETID_DATA_DIR="${pocketidService.dataDir}"
        POCKETID_STOPPED=false
        VAULT_MOUNTED=false

        # Ensure PocketID is restarted and vault unmounted on exit, even if script fails
        cleanup() {
          if [ "$POCKETID_STOPPED" = true ]; then
            echo "Ensuring PocketID service is restarted..."
            if systemctl start pocket-id.service; then
              echo "PocketID service restarted successfully"
            else
              echo "ERROR: Failed to restart PocketID service!" >&2
            fi
          fi
          if [ "$VAULT_MOUNTED" = true ]; then
            echo "Unmounting encrypted vault..."
            if ! mount-vault services unmount; then
              echo "ERROR: Failed to unmount encrypted vault!" >&2
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
        tar --exclude-caches-all --warning=no-file-changed -czf "$TAR_FILE" -C "$POCKETID_DATA_DIR" .
        chown pocket-id:backup "$TAR_FILE"
        chmod 640 "$TAR_FILE"

        # Restart pocket-id service
        echo "Restarting PocketID service..."
        systemctl start pocket-id.service
        POCKETID_STOPPED=false

        # Clean up old tar files (keep last 7 days locally)
        find "$BACKUP_DIR" -name "pocketid-data-*.tar.gz" -mtime +6 -delete

        # Mount encrypted vault and sync backups
        echo "Mounting encrypted vault..."
        mount-vault services mount
        VAULT_MOUNTED=true

        # Sync backups to remote location
        echo "Syncing backups to remote ..."
        rsync -rltD --chown=pocket-id:backup --delete-after "$BACKUP_DIR/" "${cfg.remoteBackupLocation}"

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
