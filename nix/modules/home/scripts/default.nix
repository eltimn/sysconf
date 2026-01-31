{ lib, osConfig, ... }:
let
  settings = osConfig.sysconf.settings;
in
{
  config = lib.mkMerge [
    {
      # common scripts
      home.file = {
        "bin/export-bitwarden".source = ./files/export-bitwarden;
        "bin/generate-templates".source = ./files/generate-templates;
        "bin/init-project".source = ./files/init-project;
        "bin/rm-known-host".source = ./files/rm-known-host;
        "bin/search-vscode-ext".source = ./files/search-vscode-ext;
      };
    }

    (lib.mkIf (settings.hostRole == "desktop") {
      # desktop scripts
      home.file = {
        "bin/backup-borg".source = ./files/desktop/backup-borg;
        "bin/backup-secrets".source = ./files/desktop/backup-secrets;
        "bin/backup-workstation".source = ./files/desktop/backup-workstation;
        "bin/mount-nas".source = ./files/desktop/mount-nas;
        "bin/mount-nas-dir".source = ./files/desktop/mount-nas-dir;
        "bin/reset-cosmic-theme".source = ./files/reset-cosmic-theme;
      };
    })
  ];
}
