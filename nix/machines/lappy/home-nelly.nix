{
  config,
  osConfig,
  pkgs,
  ...
}:
{

  imports = [
    ../../modules/home/desktop
  ];

  # git secrets
  sops.secrets."git/github" = { };
  sops.secrets."git/user" = { };

  # The User and Path it manages
  home = {
    username = "nelly";
    homeDirectory = "/home/nelly";
    stateVersion = "23.11";

    # Packages that should be installed to the user profile.
    packages = with pkgs; [
      git-worktree-runner
      system76-firmware
    ];

    # List of extra paths to include in the user profile.
    sessionPath = [
      "$HOME/bin"
      "$HOME/bin/common"
      "$HOME/bin/desktop"
      "$HOME/go/bin"
    ];

    # List of environment variables.
    sessionVariables = {
      EDITOR = osConfig.sysconf.users.nelly.envEditor;
      VISUAL = osConfig.sysconf.users.nelly.envEditor;
      COSMIC_DATA_CONTROL_ENABLED = 1;
    };

    # some files
    file.".config/borg/backup_dirs".text =
      "export BACKUP_DIRS='Documents Notes code secret-cipher sysconf'";
    # autostart files (run on login)
    file.".config/autostart/filen.desktop".source = ./files/filen.desktop;
    file.".config/autostart/mount-secret.desktop".source = ./files/mount-secret.desktop;
  };

  # Packages that are installed as programs also allow for configuration.
  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;
  };

  # Enable sysconf modules
  sysconf = {
    programs = {
      claude.enable = true;
      nodejs.enable = true;

      git = {
        githubIncludePath = config.sops.secrets."git/github".path;
        userIncludePath = config.sops.secrets."git/user".path;
      };
    };
  };
}
