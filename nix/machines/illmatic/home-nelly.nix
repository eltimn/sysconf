{
  osConfig,
  ...
}:
{
  home = {
    username = "nelly";
    homeDirectory = "/home/nelly";
    stateVersion = "25.11";

    sessionPath = [
      "$HOME/bin/common"
      "$HOME/bin"
    ];
    sessionVariables = {
      EDITOR = osConfig.sysconf.users.nelly.envEditor;
    };
  };

  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;
  };

  # sysconf programs & containers
  sysconf = {
    programs.backup = {
      enable = true;
      backupPaths = [
        "/mnt/backup/archives-enc"
        "/mnt/backup/ruca/nelly/sysconf"
        "/mnt/backup/ruca/nelly/zen"
        "/mnt/backup/services-enc"
        "/mnt/files"
        "/mnt/music"
        "/mnt/pictures"
      ];
      passwordPath = "/run/keys/borg-passphrase-illmatic";
    };

    programs.git = {
      githubIncludePath = "/run/keys/nelly-git-github";
      userIncludePath = "/run/keys/nelly-git-user";
    };

    services.notify.enable = true;

    services.filen-sync = {
      enable = true;
      syncPairs = [
        {
          local = "/mnt/files/Audio";
          remote = "/Audio";
          syncMode = "cloudBackup";
        }
        {
          local = "/mnt/files/Camera";
          remote = "/Camera";
          syncMode = "cloudBackup";
        }
        {
          local = "/mnt/files/Documents";
          remote = "/Documents";
          syncMode = "cloudBackup";
        }
        {
          local = "/mnt/files/Notes";
          remote = "/Notes";
          syncMode = "cloudBackup";
        }
        {
          local = "/mnt/files/secret-cipher";
          remote = "/secret-cipher";
          syncMode = "cloudBackup";
        }
      ];
      onCalendar = "hourly";
    };
  };

  systemd.user.tmpfiles.rules = [
    "z /mnt/files - - - - -" # z updates user:group only when created
    "d /mnt/files/Audio - - - - -"
    "d /mnt/files/Camera - - - - -"
    "d /mnt/files/Documents - - - - -"
    "d /mnt/files/Notes - - - - -"
    "d /mnt/files/secret-cipher - - - - -"
  ];
}
