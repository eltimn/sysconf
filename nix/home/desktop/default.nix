{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      ansible-lint
      bitwarden-desktop
      borgbackup
      caligula
      devbox
      # enpass
      # entr
      ffmpeg
      gnome-tweaks
      google-chrome
      # libnss3-tools
      libnotify
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
      vlc
      # warp-terminal
      yubikey-manager
    ];
  };
}
