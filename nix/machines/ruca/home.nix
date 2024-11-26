# https://nix-community.github.io/home-manager/options.xhtml
# https://github.com/Yumasi/nixos-home/tree/main
# https://github.com/chrisportela/dotfiles
# https://www.chrisportela.com/posts/home-manager-flake/
{ config, pkgs, vars, ... }: {

  imports = [
    ../../home/programs/direnv.nix
    ../../home/programs/git.nix
    ../../home/programs/zsh/default.nix
  ];

  fonts.fontconfig.enable = true;
  xdg.mime.enable = false; # fixes a bug where nautilus crashes

  home = {
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    username = "${vars.user}";
    homeDirectory = "/home/${vars.user}";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    stateVersion = "23.11";

    # Packages that should be installed to the user profile.
    packages = with pkgs; [
      # ack-grep
      bitwarden-cli
      bitwarden-desktop
      # devbox
      # dnsutils
      enpass
      # entr
      ffmpeg
      git
      gnome.gnome-tweaks
      google-chrome
      htop
      # libnss3-tools
      libnotify
      # logseq
      meld
      # mongodb-compass
      # neofetch
      # neovim
      # nerdfonts
      # net-tools
      nixfmt-classic
      notify-osd
      obsidian
      parcellite
      sshfs
      tldr
      tmux
      tmuxinator
      # trash-cli
      vlc
      # warp-terminal
      xclip
      yubikey-manager
    ];

    # List of extra paths to include in the user profile.
    sessionPath = [ "$HOME/.pulumi/bin" "$HOME/.turso" ];

    # List of environment variables.
    sessionVariables = {
      EDITOR = "${pkgs.lib.attrsets.getBin pkgs.vscodium}/bin/code --new-window --wait";
      # JAVA_HOME = "/usr/lib/jvm/java-17-openjdk-amd64";
    };

    # List of files to be symlinked into the user home directory.
    # file.".config/Code/User/settings.json".source = ./files/.config/Code/User/settings.json;
    file.".config/VSCodium/User/settings.json".source = ./files/.config/VSCodium/User/settings.json;
    # file.".config/git/config".source = ./files/.config/git/config;
    file.".config/git/extra.inc".source = ./files/.config/git/extra.inc;
    # file.".config/terminator/config".source = ./files/.config/terminator/config;
    file.".abcde.conf".source = ./files/.abcde.conf;
    file.".ackrc".source = ./files/.ackrc;
    file.".ansible.cfg".source = ./files/.ansible.cfg;
    # file.".gitignore".source = ./files/.gitignore;
    file.".mongoshrc.js".source = ./files/.mongoshrc.js;

    file."bin".source = ./files/bin;
  };

  # Packages that are installed as programs also allow for configuration.
  programs = {
    # Let Home Manager install and manage itself.
    home-manager.enable = true;

    # https://mynixos.com/home-manager/options/programs.vscode
    vscode = {
      enable = true;
      package = pkgs.vscodium;
      # enableExtensionUpdateCheck = false;
      # enableUpdateCheck = false;
      extensions = with pkgs.vscode-extensions; [
        bbenoist.nix
        hashicorp.terraform
        yzhang.markdown-all-in-one
      ];
      # userSettings = {
      # };
      globalSnippets = {
        fixme = {
          body = [
            "$LINE_COMMENT FIXME: $0"
          ];
          description = "Insert a FIXME remark";
          prefix = [
            "fixme"
          ];
        };
      };
    };

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "ansi";
      };
    };

    # eza = {
    #   enable = true;
    #   git = true;
    #   icons = true;
    # };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    ripgrep = {
      enable = true;
      arguments = [ ];
    };

    # tmux = {
    #   enable = true;
    #   keyMode = "vi";
    #   mouse = false;
    #   shell = "${pkgs.zsh}/bin/zsh";
    #   shortcut = "a";
    #   terminal = "screen-256color";
    #   plugins = with pkgs; [ tmuxPlugins.sensible tmuxPlugins.cpu ];
    #   extraConfig = ''
    #     set status-utf8 on
    #     set utf8 on
    #     set -g status-bg black
    #     set -g status-fg white"
    #   '';
    #   tmuxinator.enable = true;
    # };

    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };
  };

  # services = {
  #   gpg-agent = {
  #     enable = true;
  #     defaultCacheTtl = 1800;
  #     enableSshSupport = true;
  #   };
  # };
}
