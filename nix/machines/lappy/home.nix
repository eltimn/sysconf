{
  pkgs,
  vars,
  ...
}:
{

  imports = [
    ../../home/common
    ../../home/desktop
    ../../home/programs/git
    ../../home/programs/vscode
    ../../home/programs/zsh
    ../../home/programs/direnv.nix
    ../../home/programs/tmux.nix
  ];

  # The User and Path it manages
  home = {
    username = "${vars.user}";
    homeDirectory = "/home/${vars.user}";
    stateVersion = "23.11";

    # Packages that should be installed to the user profile.
    packages = with pkgs; [
      btop
      dust # better `du`
      fastfetch
      fd
      gnome-terminal # needed to run mount-secret on log in
      gocryptfs
      gum
      shellcheck
      # fd
      filen-desktop
      firefox
      gnomeExtensions.appindicator
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-dock
      gnumake
      nushell
      shellcheck
      stow
      system76-firmware
      #vivaldi
      #vivaldi-ffmpeg-codecs
      zen-browser
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
      EDITOR = "${vars.editor}";
    };

    # some files
    file.".config/borg/backup_dirs".text =
      "export BACKUP_DIRS='${builtins.concatStringsSep " " vars.backup_dirs}'";
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

    lazygit.enable = true;

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
