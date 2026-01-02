{
  pkgs,
  osConfig,
  ...
}:
{

  imports = [
    ../../home/common
    ../../home/desktop
    ../../home/gnome.nix
    ../../home/programs/git
    ../../home/programs/vscode
    ../../home/programs/zsh
    ../../home/programs/direnv.nix
    ../../home/programs/tmux.nix
    # ../../home/services/mount-secrets.nix
  ];

  # The User and Path it manages
  home = {
    username = "${osConfig.sysconf.settings.primaryUsername}";
    homeDirectory = "/home/${osConfig.sysconf.settings.primaryUsername}";
    stateVersion = "23.11";

    # Packages that should be installed to the user profile.
    packages = with pkgs; [
      claude-code
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
      EDITOR = "codium --new-window --wait";
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

    # warning: The option `programs.kitty.theme' defined here'
    # has been changed to `programs.kitty.themeFile' that has a different type.
    # Please read `programs.kitty.themeFile' documentation and update your configuration accordingly.
    # kitty = {
    #   enable = true;
    #   font = {
    #     name = "DejaVu Sans";
    #     size = 14;
    #   };
    #   shellIntegration.enableZshIntegration = true;
    #   theme = "Github";
    # };

    ghostty = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  # services = {
  #   dropbox = {
  #     enable = true;
  #     path = "${config.home.homeDirectory}/Dropbox";
  #   };
  # };

  # systemd.user.services.dropbox = {
  #   Unit = { Description = "Dropbox service"; };
  #   Install = { WantedBy = [ "default.target" ]; };
  #   Service = {
  #     ExecStart = "${pkgs.dropbox}/bin/dropbox";
  #     Restart = "on-failure";
  #   };
  # };
}
