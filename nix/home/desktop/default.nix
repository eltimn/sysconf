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
      # parcellite
      # sqlitebrowser
      # vivaldi
      # vivaldi-ffmpeg-codecs
      vlc
      # warp-terminal
      # wezterm # https://github.com/wezterm/wezterm/issues/6025
      yubikey-manager
      zen-browser
    ];
  };
}
