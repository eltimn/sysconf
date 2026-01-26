{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.mount-vault;

  # Script that handles mounting/unmounting encrypted directories
  mountVaultScript = pkgs.writeShellScriptBin "mount-vault" ''
    export PATH="${
      lib.makeBinPath [
        pkgs.coreutils
        pkgs.util-linux
        pkgs.gocryptfs
        pkgs.fuse
      ]
    }:$PATH"

    set -euo pipefail

    VAULT_BASE="/mnt/backup"
    LOCK_DIR="/run/mount-vault"

    usage() {
      echo "Usage: mount-vault <vault-name> <mount|unmount|status>"
      echo ""
      echo "Vaults:"
      echo "  services  - Encrypted services backup directory"
      echo "  archives  - Encrypted archives directory"
      echo ""
      echo "Actions:"
      echo "  mount   - Mount the encrypted directory"
      echo "  unmount - Unmount the encrypted directory (only if no other users)"
      echo "  status  - Show mount status and lock count"
      exit 1
    }

    if [[ $# -lt 2 ]]; then
      usage
    fi

    VAULT_NAME="$1"
    ACTION="$2"

    CIPHER_DIR="$VAULT_BASE/$VAULT_NAME-enc"
    MOUNT_POINT="${cfg.mountDir}/$VAULT_NAME"
    LOCK_FILE="$LOCK_DIR/$VAULT_NAME.lock"
    KEY_FILE="/run/keys/gocryptfs-$VAULT_NAME"

    # Ensure lock directory exists
    mkdir -p "$LOCK_DIR"

    is_mounted() {
      mountpoint -q "$MOUNT_POINT" 2>/dev/null
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

    do_mount() {
      if is_mounted; then
        echo "Already mounted: $MOUNT_POINT"
        increment_lock
        return 0
      fi

      # Check cipher directory exists
      if [[ ! -d "$CIPHER_DIR" ]]; then
        echo "Error: Cipher directory does not exist: $CIPHER_DIR"
        echo "Initialize with: gocryptfs -init $CIPHER_DIR"
        exit 1
      fi

      # Ensure mount point exists
      mkdir -p "$MOUNT_POINT"

      # Mount using keyfile if available, otherwise prompt for password
      if [[ -f "$KEY_FILE" ]]; then
        echo "Mounting $VAULT_NAME using keyfile..."
        ${pkgs.gocryptfs}/bin/gocryptfs -q -passfile "$KEY_FILE" "$CIPHER_DIR" "$MOUNT_POINT"
      else
        echo "Mounting $VAULT_NAME (password required)..."
        ${pkgs.gocryptfs}/bin/gocryptfs "$CIPHER_DIR" "$MOUNT_POINT"
      fi

      increment_lock
      echo "Mounted: $MOUNT_POINT"
    }

    do_unmount() {
      if ! is_mounted; then
        echo "Not mounted: $MOUNT_POINT"
        # Reset lock count if not mounted
        echo "0" > "$LOCK_FILE"
        return 0
      fi

      decrement_lock
      local count
      count=$(get_lock_count)

      if [[ $count -gt 0 ]]; then
        echo "Unmount deferred: $count other process(es) still using $VAULT_NAME"
        return 0
      fi

      echo "Unmounting $VAULT_NAME..."
      ${pkgs.fuse}/bin/fusermount -u "$MOUNT_POINT"
      echo "Unmounted: $MOUNT_POINT"
    }

    do_status() {
      echo "Vault: $VAULT_NAME"
      echo "Cipher: $CIPHER_DIR"
      echo "Mount:  $MOUNT_POINT"
      if is_mounted; then
        echo "Status: MOUNTED"
      else
        echo "Status: NOT MOUNTED"
      fi
      echo "Lock count: $(get_lock_count)"
    }

    case "$ACTION" in
      mount)
        do_mount
        ;;
      unmount)
        do_unmount
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
  options.sysconf.services.mount-vault = {
    enable = lib.mkEnableOption "mount-vault helper for encrypted directories";
    package = lib.mkOption {
      type = lib.types.package;
      description = "The mount-vault script as a package.";
      default = mountVaultScript;
      internal = true;
    };
    mountDir = lib.mkOption {
      type = lib.types.path;
      description = "Path to the base mounting directory.";
      default = "/srv/vaults";
    };
  };

  config = lib.mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.gocryptfs
    ];

    # Ensure the lock directory exists
    systemd.tmpfiles.rules = [
      "d /run/mount-vault 0755 root root -"
      "d ${cfg.mountDir} 0750 root root -"
    ];
  };
}
