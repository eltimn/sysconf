{ config, pkgs, username, ... }: {

  imports = [
    ../../home/programs/direnv.nix
    ../../home/programs/git
    ../../home/programs/zsh
  ];

  # The User and Path it manages
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "23.11";

    packages = with pkgs; [ htop gnumake neovim nixfmt-classic stow ];

    # List of files to be symlinked into the user home directory.
    # file.".tmux.conf".source = ./files/.tmux.conf;
  };

  # Packages that are installed as programs also allow for configuration.
  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;

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
}
