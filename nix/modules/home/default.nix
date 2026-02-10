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
    wev
    # wezterm # https://github.com/wezterm/wezterm/issues/6025
    wl-color-picker
    yubioath-flutter
    yubikey-manager
  ];
in
{
  imports = [
    ./containers
    ./programs
    ./scripts
    ./services
  ];

  options.sysconf.settings = {
    secretCipherPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the secret-cipher directory.";
      default = "${config.home.homeDirectory}/secret-cipher";
    };
  };

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
      sysconf.programs = {
        bat.enable = true;
        direnv.enable = true;
        git.enable = true;
        tmux.enable = true;
        tv.enable = true;
        zellij.enable = true;
        zsh.enable = true;
      };
    }

    (lib.mkIf (settings.hostRole == "desktop") {
      # Desktop-specific modules
      sysconf.programs = {
        chromium.enable = true;
        firefox.enable = true;
        foot.enable = true;
        ghostty.enable = true;
        goose.enable = true;
        opencode.enable = true;
        rofi.enable = true;
        vscode.enable = true;
        zed-editor.enable = true;
      };
    })
  ];
}
