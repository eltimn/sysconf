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
          storage =
            let
              passPath = config.sops.secrets."borg_passphrase_${cfg.host}".path;
            in
            {
              encryptionPasscommand = "${pkgs.coreutils-full}/bin/cat ${passPath}";
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

    # SOPS secret for borg environment variables
    sops.secrets."borg_passphrase_${cfg.host}" = { };
  };
}
