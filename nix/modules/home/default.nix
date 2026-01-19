{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
let
  settings = osConfig.sysconf.settings;

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
    nix-prefetch-git
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
    sqlitestudio
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
    ./programs
    ./services
  ];

  config = lib.mkMerge [
    {
      home = {
        packages = basePkgs ++ lib.optionals (settings.hostRole == "desktop") desktopPkgs;
      };

      sops = {
        age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
        age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
        defaultSopsFile = "${osConfig.sysconf.system.sops.secretsPath}/secrets-enc.yaml";
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

    (lib.mkIf (settings.hostRole == "desktop") {
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
  ];
}
