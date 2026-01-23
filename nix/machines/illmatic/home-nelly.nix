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
        "/mnt/backup/archives"
        "/mnt/backup/rotozen"
        "/mnt/backup/ruca/nelly/Audio"
        "/mnt/backup/ruca/nelly/Documents"
        "/mnt/backup/ruca/nelly/Notes"
        "/mnt/backup/ruca/nelly/secret-cipher"
        "/mnt/backup/ruca/nelly/sysconf"
        "/mnt/backup/ruca/nelly/workspaces"
        "/mnt/backup/ruca/nelly/zen"
        "/mnt/backup/services"
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
  };
}
