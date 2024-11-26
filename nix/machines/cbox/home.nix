{ config, pkgs, username, ... }: {

  # The User and Path it manages
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "23.11";

    packages = with pkgs; [ git htop gnumake neovim nixfmt ripgrep stow zsh ];

    # sessionPath = [ "$HOME/.pulumi/bin" ];
    # sessionVariables = {
    #   EDITOR =
    #     "${pkgs.lib.attrsets.getBin pkgs.vscode}/bin/code --new-window --wait";
    # };

    # List of files to be symlinked into the user home directory.
    file.".oh-my-zsh-custom".source = ./files/.oh-my-zsh-custom;
    # file.".tmux.conf".source = ./files/.tmux.conf;
  };

  # Packages that are installed as programs also allow for configuration.
  programs = {
    # Let Home Manager manage itself
    home-manager.enable = true;

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "ansi";
      };
    };

    direnv = {
      enable = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

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

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    zsh = {
      enable = true;
      enableCompletion = true;
      autosuggestion.enable = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "alanpeabody"; # https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
        custom = "$HOME/.oh-my-zsh-custom";
        plugins = [ "copyfile" "copypath" "colorize" ];
      };
    };
  };
}
