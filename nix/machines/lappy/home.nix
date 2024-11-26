{ config, pkgs, username, ... }:
let filen = (pkgs.callPackage ./pkgs/filen.nix { });
in {
  imports = [
    ../../home/desktop.nix
    ../../home/files.nix
    ../../home/programs/direnv.nix
    ../../home/programs/git
    ../../home/programs/vscode
    ../../home/programs/zsh
  ];

  # The User and Path it manages
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "23.11";

    packages = with pkgs; [
      firefox
      gnomeExtensions.appindicator
      gnomeExtensions.clipboard-indicator
      gnomeExtensions.dash-to-dock
      gnumake
      stow
    ];

    sessionPath = [ "$HOME/bin" ];
    sessionVariables = {
      EDITOR = "${
          pkgs.lib.attrsets.getBin pkgs.vscodium
        }/bin/code --new-window --wait";
    };
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

    tmux = {
      enable = true;
      keyMode = "vi";
      mouse = false;
      shell = "${pkgs.zsh}/bin/zsh";
      shortcut = "a";
      terminal = "screen-256color";
      extraConfig = ''
        set -g status-bg blue
        set -g status-fg white
        set  -g base-index      1
        setw -g pane-base-index 1
      '';
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
