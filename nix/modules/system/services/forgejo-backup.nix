{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.forgejo-backup;
  settings = config.sysconf.settings;
  forgejoService = config.services.forgejo;
in
{
  options.sysconf.services.forgejo-backup = {
    enable = lib.mkEnableOption "forgejo-backup";

    repo = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = settings.borgRepo;
      description = "The Borg repository to use for backups. Defaults to system borgRepo setting.";
    };

    passwordPath = lib.mkOption {
      type = lib.types.str;
      default = "/run/secrets/forgejo-borg-passphrase";
      description = "Path to the borg passphrase file (defaults to /run/secrets/forgejo-borg-passphrase).";
    };

    backupDir = lib.mkOption {
      type = lib.types.str;
      default = "/var/backups/forgejo";
      description = "Directory to store temporary backup files.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Allow forgejo user to manage forgejo service for backups
    security.polkit.extraConfig = ''
      polkit.addRule(function(action, subject) {
        if (action.id == "org.freedesktop.systemd1.manage-units" &&
            action.lookup("unit") == "forgejo.service" &&
            subject.user == "forgejo") {
          return polkit.Result.YES;
        }
      });
    '';

    # Ensure backup directory exists
    systemd.tmpfiles.rules = [
      "d ${cfg.backupDir} 0700 forgejo forgejo -"
    ];

    systemd.services.forgejo-backup = {
      description = "Forgejo database and data backup";
      unitConfig = {
        OnFailure = "notify@%i.service";
      };

      serviceConfig = {
        Type = "oneshot";
        User = "forgejo";
        Group = "forgejo";
      };

      path = with pkgs; [
        borgbackup
        forgejoService.package
      ];

      script = ''
        set -e

        BACKUP_DIR="${cfg.backupDir}"
        FORGEJO_WORK_DIR="${forgejoService.stateDir}"
        TIMESTAMP=$(date +%Y%m%d_%H%M%S)
        DUMP_FILE="$BACKUP_DIR/forgejo-dump-$TIMESTAMP.zip"

        echo "Starting Forgejo backup..."

        # Stop forgejo service for consistent backup
        echo "Stopping Forgejo service..."
        systemctl stop forgejo.service

        # Use forgejo dump to create backup
        echo "Running forgejo dump..."
        cd "$BACKUP_DIR"
        ${forgejoService.package}/bin/forgejo dump \
          --work-path "$FORGEJO_WORK_DIR" \
          --file "$DUMP_FILE" \
          --skip-log

        echo "Forgejo dump created: $DUMP_FILE"

        # Restart forgejo service
        echo "Restarting Forgejo service..."
        systemctl start forgejo.service

        # Export borg passphrase
        export BORG_PASSPHRASE="$(cat ${cfg.passwordPath})"
        export BORG_REPO="${cfg.repo}"

        # Create borg backup
        echo "Creating Borg backup..."
        borg create \
          --stats \
          --compression auto,zstd \
          "::forgejo-{now:%Y-%m-%d-%H%M%S}" \
          "$DUMP_FILE"

        # Prune old backups
        echo "Pruning old backups..."
        borg prune \
          --keep-daily 7 \
          --keep-weekly 4 \
          --keep-monthly 6

        # Clean up old dump files (keep last 3 days locally)
        find "$BACKUP_DIR" -name "forgejo-dump-*.zip" -mtime +3 -delete

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
