{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.sysconf.settings;

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
  options.sysconf.settings = {
    desktopEnvironment = lib.mkOption {
      type = lib.types.str;
      default = "none"; # cosmic|gnome|none
      description = "Desktop Environment used.";
    };

    hostRole = lib.mkOption {
      type = lib.types.str;
      default = "server"; # desktop|server
      description = "Is this being used on a desktop or server.";
    };
  };

  config = {
    home = {
      packages =
        with pkgs;
        [
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
        ]
        ++ lib.optionals (cfg.hostRole == "desktop") desktopPkgs;
    };

    sops = {
      age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      defaultSopsFile = ../../../../secrets/secrets-enc.yaml;
      defaultSopsFormat = "yaml";
    };

    imports = [
      ./programs
      ./services
    ];
  };
}
