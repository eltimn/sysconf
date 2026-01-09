{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.backup;
in
{
  options.sysconf.programs.backup = {
    enable = lib.mkEnableOption "backup";
    backupPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [ "${config.home.homeDirectory}/sysconf" ];
      description = "List of paths to backup.";
    };
    repo = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The Borg repository to use for backups.";
    };
    host = lib.mkOption {
      type = lib.types.str;
      default = "";
      description = "The host this is running on.";
    };
    passwordPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to the password file.";
      default = null;
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ pkgs.borgmatic ];

    programs.borgmatic = {
      enable = true;
      backups = {
        main = {
          location = {
            sourceDirectories = cfg.backupPaths;
            repositories = [
              cfg.repo
            ];
            excludeHomeManagerSymlinks = true;
            extraConfig = {
              exclude_caches = true;
              exclude_patterns = [
                "/home/*/.cache"
                ".nix-profile"
                "node_modules"
              ];
            };
          };
          storage = {
            encryptionPasscommand = "${pkgs.coreutils-full}/bin/cat ${cfg.passwordPath}";
            extraConfig = {
              compression = "auto,zstd";
              archive_name_format = "{hostname}-{now:%Y-%m-%d-%H%M%S}";
            };
          };
          retention = {
            keepDaily = 7;
            keepWeekly = 4;
            keepMonthly = 6;
          };
        };
      };
    };

    services.borgmatic = {
      enable = true;
      frequency = "daily";
    };

    systemd.user.services.borgmatic = {
      Service = {
        ExecStartPre = lib.mkForce [ ]; # Remove the 3 minute sleep
        ExecStart = lib.mkForce [
          "" # Clear the existing ExecStart
          ''
            ${pkgs.borgmatic}/bin/borgmatic \
              --stats \
              --verbosity 0 \
              --list \
              --syslog-verbosity 1
          ''
        ];
      };
    };
  };
}
