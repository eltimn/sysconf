{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.services.filen-sync;

  # Generate the syncPairs.json content
  syncPairsJson = builtins.toJSON (
    map (pair: {
      inherit (pair) local remote syncMode;
    }) cfg.syncPairs
  );

  syncPairsFile = pkgs.writeText "syncPairs.json" syncPairsJson;
in
{
  options.sysconf.services.filen-sync = {
    enable = lib.mkEnableOption "filen-sync";

    authConfigFile = lib.mkOption {
      type = lib.types.str;
      default = "/run/keys/filen-cli-auth-config";
      description = "Path to the Filen auth config file (deployed by Colmena).";
    };

    syncPairs = lib.mkOption {
      type = lib.types.listOf (
        lib.types.submodule {
          options = {
            local = lib.mkOption {
              type = lib.types.str;
              description = "Local directory path to sync.";
            };
            remote = lib.mkOption {
              type = lib.types.str;
              description = "Remote path on Filen cloud.";
            };
            syncMode = lib.mkOption {
              type = lib.types.enum [
                "twoWay"
                "localToCloud"
                "localBackup"
                "cloudToLocal"
                "cloudBackup"
              ];
              default = "twoWay";
              description = ''
                Sync mode:
                - twoWay: Mirror every action in both directions
                - localToCloud: Mirror local changes to cloud only
                - localBackup: Upload to cloud, never delete
                - cloudToLocal: Mirror cloud changes to local only
                - cloudBackup: Download from cloud, never delete
              '';
            };
          };
        }
      );
      default = [ ];
      description = "List of sync pairs.";
    };

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "hourly";
      description = "Systemd calendar expression for sync schedule.";
    };

    dataDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/.local/share/filen";
      description = "Working directory for Filen CLI (stores cache, etc.).";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      filen-cli
    ];

    # Ensure data directory exists
    systemd.user.tmpfiles.rules = [
      "d ${cfg.dataDir} 0700 - - -"
    ];

    systemd.user.services.filen-sync = {
      Unit = {
        Description = "Filen cloud sync";
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
        OnFailure = [ "notify@%i.service" ];
      };

      Service = {
        Type = "oneshot";
        WorkingDirectory = cfg.dataDir;
        ExecStart = pkgs.writeShellScript "filen-sync" ''
          set -e

          AUTH_CONFIG="${cfg.dataDir}/.filen-cli-auth-config"

          # Cleanup auth config on exit (success or failure)
          cleanup() {
            ${pkgs.coreutils}/bin/rm -f "$AUTH_CONFIG"
          }
          trap cleanup EXIT

          # Ensure source auth config exists and is readable
          if [ ! -r "${cfg.authConfigFile}" ]; then
            echo "filen-sync: auth config file not found or not readable: ${cfg.authConfigFile}" >&2
            exit 1
          fi
          # Copy auth config from tmpfs to working directory
          ${pkgs.coreutils}/bin/cp "${cfg.authConfigFile}" "$AUTH_CONFIG"
          ${pkgs.coreutils}/bin/chmod 400 "$AUTH_CONFIG"

          # Run sync
          ${pkgs.filen-cli}/bin/filen sync ${syncPairsFile}
        '';
      };
    };

    systemd.user.timers.filen-sync = {
      Unit = {
        Description = "Filen sync timer";
      };

      Timer = {
        OnCalendar = cfg.onCalendar;
        Persistent = true;
        RandomizedDelaySec = "5m";
      };

      Install = {
        WantedBy = [ "timers.target" ];
      };
    };
  };
}
