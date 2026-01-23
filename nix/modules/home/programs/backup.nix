{
  config,
  lib,
  osConfig,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.programs.backup;
  settings = osConfig.sysconf.settings;
in
{
  options.sysconf.programs.backup = {
    enable = lib.mkEnableOption "backup";
    backupPaths = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [
        "${config.home.homeDirectory}/sysconf"
        "/mnt/backup/services"
      ];
      description = "List of paths to backup.";
    };
    repo = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = settings.borgRepo;
      description = "The Borg repository to use for backups.";
    };
    passwordPath = lib.mkOption {
      type = lib.types.str;
      description = "Path to the password file.";
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
      Unit = {
        OnFailure = "notify@%i.service";
      };
      Service = {
        ExecStartPre = lib.mkForce [ ]; # Remove the 3 minute sleep
        ExecStart = lib.mkForce [
          "" # Clear the existing ExecStart
          ''
            ${pkgs.borgmatic}/bin/borgmatic \
              --verbosity 0 \
              --syslog-verbosity 0
          ''
        ];
      };
    };
  };
}
