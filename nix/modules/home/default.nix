{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  cfg = config.sysconf.settings;

  basePkgs = with pkgs; [
    # ack-grep
    bitwarden-cli
    doctl
    dust # better `du`
    fastfetch
    fd
    gh
    git
    gnumake
    gocryptfs
    libsecret
    mongodb-tools
    mongosh
    neovim
    nushell
    podman-tui
    shellcheck
    # tmux
    # tmuxinator
    # trash-cli
    xclip
  ];

  desktopPkgs = with pkgs; [
    bitwarden-desktop
    borgbackup
    caligula
    devbox
    # enpass
    # entr
    ffmpeg
    filen-desktop
    firefox
    git-worktree-runner
    google-chrome
    # libnss3-tools
    libnotify
    lm_sensors
    # logseq
    meld
    # mongodb-compass
    # neofetch
    # nerdfonts
    # net-tools
    nixfmt-rfc-style
    nixpkgs-lint-community
    notify-osd
    obsidian
    # sqlitebrowser
    # sqlitestudio
    # vivaldi
    # vivaldi-ffmpeg-codecs
    vhs
    vlc
    # warp-terminal
    # wezterm # https://github.com/wezterm/wezterm/issues/6025
    wl-color-picker
    yubioath-flutter
    yubikey-manager
    zen-browser
  ];
in
{
  imports = [
    ./containers
    ./desktop
    ./programs
    ./services
  ];

  options.sysconf.settings = {
    hostRole = lib.mkOption {
      type = lib.types.str;
      default = "server"; # desktop|server
      description = "Is this being used on a desktop or server.";
    };
  };

  config = lib.mkMerge [
    {
      home = {
        packages = basePkgs ++ lib.optionals (cfg.hostRole == "desktop") desktopPkgs;
      };

      sops = {
        age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
        defaultSopsFile = ../../../secrets/secrets-enc.yaml;
        defaultSopsFormat = "yaml";
      };

      # enable some modules
      # sysconf.programs.backup.enable = true;
      sysconf.programs.bat.enable = true;
      sysconf.programs.direnv.enable = true;
      sysconf.programs.git.enable = true;
      sysconf.programs.micro.enable = true;
      sysconf.programs.tmux.enable = true;
      sysconf.programs.zsh.enable = true;
    }

    (lib.mkIf (cfg.hostRole == "desktop") {
      # Desktop-specific modules
      sysconf.programs.chromium.enable = true;
      sysconf.programs.firefox.enable = true;
      sysconf.programs.ghostty.enable = true;
      sysconf.programs.goose.enable = true;
      sysconf.programs.opencode.enable = true;
      sysconf.programs.rofi.enable = true;
      sysconf.programs.vscode.enable = true;
      sysconf.programs.zed-editor.enable = true;
    })

    (lib.mkIf (osConfig.sysconf.settings.desktopEnvironment == "gnome") {
      sysconf.gnome.enable = true;
    })
    (lib.mkIf (osConfig.sysconf.settings.desktopEnvironment == "cosmic") {
      sysconf.cosmic.enable = true;
    })
  ];
}
