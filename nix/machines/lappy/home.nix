{ config, pkgs, username, ... }:
let filen = (pkgs.callPackage ./pkgs/filen.nix { });
in {
  # The User and Path it manages
  home = {
    username = "${username}";
    homeDirectory = "/home/${username}";
    stateVersion = "23.11";

    packages = with pkgs; [
      enpass
      filen
      ffmpeg
      git
      htop
      firefox
      gnome.gnome-tweaks
      libnotify
      gnomeExtensions.appindicator
      gnumake
      neovim
      nixfmt
      notify-osd
      parcellite
      ripgrep
      sshfs
      stow
      tmux
      vscode
      xclip
      yubikey-manager
      zsh
    ];

    sessionPath = [ "$HOME/.pulumi/bin" ];
    sessionVariables = {
      EDITOR =
        "${pkgs.lib.attrsets.getBin pkgs.vscode}/bin/code --new-window --wait";
    };

    # List of files to be symlinked into the user home directory.
    file.".config/Code/User/settings.json".source =
      ./files/.config/Code/User/settings.json;
    file.".config/git/config".source = ./files/.config/git/config;
    file.".oh-my-zsh-custom".source = ./files/.oh-my-zsh-custom;
    file.".ackrc".source = ./files/.ackrc;
    file.".ansible.cfg".source = ./files/.ansible.cfg;
    file.".gitignore".source = ./files/.gitignore;
    file.".mongoshrc.js".source = ./files/.mongoshrc.js;
    file.".abcde.conf".source = ./files/.abcde.conf;
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

    kitty = {
      enable = true;
      font = {
        name = "DejaVu Sans";
        size = 14;
      };
      shellIntegration.enableZshIntegration = true;
      theme = "Github";
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
      enableAutosuggestions = true;
      syntaxHighlighting.enable = true;

      oh-my-zsh = {
        enable = true;
        theme = "alanpeabody"; # https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
        custom = "$HOME/.oh-my-zsh-custom";
        plugins = [ "copyfile" "copypath" "colorize" ];
      };
    };
  };

  # services.dropbox.enable = true;

  xdg.desktopEntries = {
    filen = {
      name = "Filen";
      genericName = "File Syncer";
      exec = "filen";
      terminal = false;
      categories = [ "Application" "Network" ];
    };
  };
}
