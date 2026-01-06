{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
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
  };
}
