{ pkgs, ... }:
{
  home = {
    # List of files to be symlinked into the user home directory.
    file.".abcde.conf".source = ./files/.abcde.conf;
    file.".background-image".source = ./files/Lightning_Neuro.jpg;

    file.".config/backup" = {
      source = ./files/config/backup;
      recursive = true;
    };

    file."bin/desktop" = {
      source = ./files/bin;
      recursive = true;
    };

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
