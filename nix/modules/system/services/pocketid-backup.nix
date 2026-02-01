{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.pocketid-backup;
  pocketidService = config.services.pocket-id;
  zfsVault = config.sysconf.services.zfs-vault;
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
      default = "${zfsVault.mountDir}/backup/pocketid";
    };
  };

  config = lib.mkIf cfg.enable {
    # Enable zfs-vault dependency
    sysconf.services.zfs-vault.enable = true;
    sysconf.services.notify.enable = true;

    systemd = {
      # Ensure backup directory exists with correct permissions
      tmpfiles.rules = [
        "d ${cfg.backupDir} 0750 pocket-id backup -"
      ];

      services.pocketid-backup = {
        description = "PocketID database and data backup";
        unitConfig = {
          OnFailure = "notify@%i.service";
        };

        # Wait for ZFS encryption key service before starting
        after = [ "zfs-encryption-private-key.service" ];
        wants = [ "zfs-encryption-private-key.service" ];

        serviceConfig = {
          Type = "oneshot";
          # Run as root to have permission to stop/start pocket-id service
          User = "root";
          Group = "root";
        };

        path = [
          zfsVault.package
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
          VAULT_UNLOCKED=false

          # Ensure PocketID is restarted and vault locked on exit, even if script fails
          cleanup() {
            if [ "$POCKETID_STOPPED" = true ]; then
              echo "Ensuring PocketID service is restarted..."
              if systemctl start pocket-id.service; then
                echo "PocketID service restarted successfully"
              else
                echo "ERROR: Failed to restart PocketID service!" >&2
              fi
            fi
            if [ "$VAULT_UNLOCKED" = true ]; then
              echo "Locking ZFS vault..."
              if ! zfs-vault lock; then
                echo "ERROR: Failed to lock ZFS vault. Dataset may remain unlocked." >&2
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

          # Unlock ZFS vault and sync backups
          echo "Unlocking ZFS vault..."
          zfs-vault unlock
          VAULT_UNLOCKED=true

          # Sync backups to remote location
          echo "Syncing backups to remote ..."
          rsync -rltD --chown=pocket-id:backup --delete-after "$BACKUP_DIR/" "${cfg.remoteBackupLocation}"

          echo "PocketID backup completed successfully"
        '';
      };

      # Timer for automatic backups
      timers.pocketid-backup = {
        description = "PocketID backup timer";
        wantedBy = [ "timers.target" ];
        timerConfig = {
          OnCalendar = "daily";
          Persistent = true;
          RandomizedDelaySec = "1h";
        };
      };
    };
  };
}
