{ pkgs, vars, ... }:
let
  filen-desktop = (pkgs.callPackage ../../home/pkgs/filen-desktop.nix { });
in
{
  imports = [
    ../../home/common
    ../../home/desktop
    ../../home/programs/direnv.nix
    ../../home/programs/git
    ../../home/programs/vscode
    ../../home/programs/zsh
  ];

  # The User and Path it manages
  home = {
    username = "${vars.user}";
    homeDirectory = "/home/${vars.user}";
    stateVersion = "23.11";

    packages = with pkgs; [
      filen-desktop
      firefox
      gnomeExtensions.appindicator
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-dock
      gnumake
      shellcheck
      stow
      system76-firmware
      vivaldi
      vivaldi-ffmpeg-codecs
      wezterm
    ];

    sessionPath = [
      "$HOME/bin"
      "$HOME/bin/common"
      "$HOME/bin/desktop"
      "$HOME/go/bin"
    ];
    sessionVariables = {
      EDITOR = "${vars.editor}";
    };

    # some files
    file.".config/borg/backup_dirs".text = "export BACKUP_DIRS='code secret sysconf'";
    file.".config/autostart/filen.desktop".source = ./files/filen.desktop;
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

  xdg.desktopEntries = {
    filen = {
      name = "Filen";
      genericName = "File Syncer";
      exec = "filen-desktop";
      terminal = false;
      categories = [
        "Application"
        "Network"
      ];
    };
  };
}
