{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.zfs-vault;

  # Script that handles unlocking/locking ZFS encrypted datasets
  zfsVaultScript = pkgs.writeShellScriptBin "zfs-vault" ''
    export PATH="${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.zfs
      ]
    }:$PATH"

    set -euo pipefail

    LOCK_DIR="/run/zfs-vault"

    usage() {
      echo "Usage: zfs-vault <unlock|lock|status>"
      echo ""
      echo "Actions:"
      echo "  unlock - Load encryption key and mount dataset"
      echo "  lock   - Unmount dataset and unload encryption key"
      echo "  status - Show encryption and mount status"
      exit 1
    }

    if [[ $# -lt 1 ]]; then
      usage
    fi

    ACTION="$1"
    DATASET="${cfg.dataset}"
    KEY_FILE="${cfg.keyFile}"

    # Ensure lock directory exists
    mkdir -p "$LOCK_DIR"

    LOCK_FILE="$LOCK_DIR/lock"

    is_key_loaded() {
      local keystatus
      keystatus=$(zfs get -H -o value keystatus "$DATASET" 2>/dev/null || echo "unavailable")
      [[ "$keystatus" == "available" ]]
    }

    is_mounted() {
      local mounted
      mounted=$(zfs get -H -o value mounted "$DATASET" 2>/dev/null || echo "no")
      [[ "$mounted" == "yes" ]]
    }

    get_lock_count() {
      if [[ -f "$LOCK_FILE" ]]; then
        cat "$LOCK_FILE"
      else
        echo "0"
      fi
    }

    increment_lock() {
      local count
      count=$(get_lock_count)
      echo $((count + 1)) > "$LOCK_FILE"
    }

    decrement_lock() {
      local count
      count=$(get_lock_count)
      if [[ $count -gt 0 ]]; then
        echo $((count - 1)) > "$LOCK_FILE"
      fi
    }

    do_unlock() {
      if is_key_loaded && is_mounted; then
        echo "Dataset already mounted: $DATASET"
        increment_lock
        return 0
      fi

      if ! is_key_loaded; then
        if [[ ! -f "$KEY_FILE" ]]; then
          echo "Error: Key file does not exist: $KEY_FILE"
          echo "Ensure the Colmena key service has deployed the key."
          exit 1
        fi

        echo "Loading encryption key for $DATASET..."
        zfs load-key -L "file://$KEY_FILE" "$DATASET"
        echo "Key loaded successfully."
      fi

      if ! is_mounted; then
        echo "Mounting $DATASET and all children..."
        zfs mount -R "$DATASET"
        echo "Dataset mounted."
      fi

      increment_lock
    }

    do_lock() {
      decrement_lock
      local count
      count=$(get_lock_count)

      if [[ $count -gt 0 ]]; then
        echo "Lock deferred: $count other process(es) still using $DATASET"
        return 0
      fi

      if is_mounted; then
        echo "Unmounting $DATASET and children..."
        # Unmount child datasets first (reverse order)
        zfs list -r -H -o name "$DATASET" | tail -n +2 | tac | while read -r child; do
          zfs unmount "$child" 2>/dev/null || true
        done
        zfs unmount "$DATASET" || true
      else
        echo "Dataset not mounted: $DATASET"
      fi

      if is_key_loaded; then
        echo "Unloading encryption key for $DATASET..."
        zfs unload-key "$DATASET"
        echo "Key unloaded successfully."
      else
        echo "Key not loaded for $DATASET"
      fi
    }

    do_status() {
      echo "Dataset: $DATASET"
      echo "Key file: $KEY_FILE"
      echo ""

      local keystatus mounted
      keystatus=$(zfs get -H -o value keystatus "$DATASET" 2>/dev/null || echo "unknown")
      mounted=$(zfs get -H -o value mounted "$DATASET" 2>/dev/null || echo "unknown")

      echo "Key status: $keystatus"
      echo "Mounted: $mounted"

      if [[ -f "$KEY_FILE" ]]; then
        echo "Key file: exists"
      else
        echo "Key file: NOT FOUND"
      fi

      echo "Lock count: $(get_lock_count)"
    }

    case "$ACTION" in
      unlock)
        do_unlock
        ;;
      lock)
        do_lock
        ;;
      status)
        do_status
        ;;
      *)
        usage
        ;;
    esac
  '';
in
{
  options.sysconf.services.zfs-vault = {
    enable = lib.mkEnableOption "zfs-vault helper for encrypted ZFS datasets";

    package = lib.mkOption {
      type = lib.types.package;
      description = "The zfs-vault script as a package.";
      default = zfsVaultScript;
      internal = true;
    };

    dataset = lib.mkOption {
      type = lib.types.str;
      description = "The ZFS dataset to manage.";
      default = "mediapool/private";
    };

    keyFile = lib.mkOption {
      type = lib.types.path;
      description = "Path to the encryption key file (deployed by Colmena).";
      default = "/run/keys/zfs-encryption-private";
    };

    mountDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to the base mounting directory for the dataset.";
      default = "/srv/media/private";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      zfsVaultScript
    ];

    # Ensure the lock directory exists
    systemd.tmpfiles.rules = [
      "d /run/zfs-vault 0755 root root -"
    ];
  };
}
