{ lib, osConfig, ... }:
let
  settings = osConfig.sysconf.settings;
in
{
  config = lib.mkMerge [
    {
      # common scripts
      home.file."bin/export-bitwarden".source = ./files/export-bitwarden;
      home.file."bin/reset-cosmic-theme".source = ./files/reset-cosmic-theme;
      home.file."bin/rm-known-host".source = ./files/rm-known-host;
      home.file."bin/search-vscode-ext".source = ./files/search-vscode-ext;
      # home.file."bin/full-upgrade".source = ./files/full-upgrade;
    }

    (lib.mkIf (settings.hostRole == "desktop") {
      # desktop scripts
      home.file."bin/backup-borg".source = ./files/desktop/backup-borg;
      home.file."bin/backup-secrets".source = ./files/desktop/backup-secrets;
      home.file."bin/backup-workstation".source = ./files/desktop/backup-workstation;
      home.file."bin/mount-nas".source = ./files/desktop/mount-nas;
      home.file."bin/mount-nas-dir".source = ./files/desktop/mount-nas-dir;
    })
  ];
}
