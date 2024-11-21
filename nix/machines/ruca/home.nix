# https://nix-community.github.io/home-manager/options.xhtml
# https://github.com/Yumasi/nixos-home/tree/main
# https://github.com/chrisportela/dotfiles
# https://www.chrisportela.com/posts/home-manager-flake/
{ config, pkgs, vars, ... }: {

  imports = [ ../../modules/shell/direnv.nix ../../modules/shell/zsh.nix ];

  fonts.fontconfig.enable = true;

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
      # enpass
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
      vscode
      # warp-terminal
      xclip
      yubikey-manager
    ];

    # List of extra paths to include in the user profile.
    sessionPath = [ "$HOME/.pulumi/bin" "$HOME/.turso" ];

    # List of environment variables.
    sessionVariables = {
      EDITOR = "${pkgs.lib.attrsets.getBin pkgs.vscode}/bin/code --new-window --wait";
      # JAVA_HOME = "/usr/lib/jvm/java-17-openjdk-amd64";
    };

    # List of files to be symlinked into the user home directory.
    file.".config/Code/User/settings.json".source = ./files/.config/Code/User/settings.json;
    # file.".config/git/config".source = ./files/.config/git/config;
    file.".config/git/extra.inc".source = ./files/.config/git/extra.inc;
    # file.".config/terminator/config".source = ./files/.config/terminator/config;
    file.".config/zsh/funcs".source = ./files/.config/zsh/funcs;
    file.".oh-my-zsh-custom".source = ./files/.oh-my-zsh-custom;
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

    bat = {
      enable = true;
      config = {
        pager = "less -FR";
        theme = "ansi";
      };
    };

    eza = {
      enable = true;
      git = true;
      icons = true;
    };

    fzf = {
      enable = true;
      enableZshIntegration = true;
    };

    git = {
      enable = true;
      aliases = {
        au = "add -u .";
        br = "branch";
        ci = "commit";
        cia = "commit --amend";
        co = "checkout";
        df = "difftool";
        dff = "diff --no-ext-diff";
        st = "status";
        cleanup =
          "!git branch --merged main | grep -v '^*\\|main' | xargs -r -n 1 git branch -D";
        remove = "git rm --cached";
        lg = "log --pretty='tformat:%h %an (%ai): %s' --topo-order --graph";
      };
      difftastic.enable = true;
      # extraConfig = {
      #   diff = {
      #     external =
      #       "${pkgs.vscode}/bin/code --wait --new-window --diff $LOCAL $REMOTE";
      #   };
      # };
      ignores = [
        "*.com"
        "*.class"
        "*.dll"
        "*.exe"
        "*.o"
        "*.so"
        "*.pyc"
        "*.7z"
        "*.dmg"
        "*.gz"
        "*.iso"
        "*.jar"
        "*.rar"
        "*.tar"
        "*.zip"
        "*.log"
        "*.sql"
        "*.sqlite"
        ".DS_Store?"
        "ehthumbs.db"
        "Icon?"
        "Thumbs.db"
        ".hg/"
        ".hgignore"
        "*.sublime-project"
        "*.sublime-workspace"
        ".svn/"
      ];
      includes = [
        { path = "extra.inc"; }
        { path = "gitconfig.d/github.inc"; }
        { path = "gitconfig.d/user.inc"; }
      ];
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
