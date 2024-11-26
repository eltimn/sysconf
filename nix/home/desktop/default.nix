{ pkgs, ... }:
let filen = (pkgs.callPackage ../pkgs/filen.nix { });
in {
  home = {
    # List of files to be symlinked into the user home directory.
    file.".abcde.conf".source = ./files/.abcde.conf;

    file.".config/backup" = {
      source = ./files/config/backup;
      recursive = true;
    };

    file."bin/desktop" = {
      source = ./files/bin;
      recursive = true;
    };

    packages = with pkgs; [
      bitwarden-desktop
      caligula
      devbox
      # dropbox
      enpass
      # entr
      ffmpeg
      filen
      gnome.gnome-tweaks
      google-chrome
      # libnss3-tools
      libnotify
      # logseq
      meld
      # mongodb-compass
      # neofetch
      # nerdfonts
      # net-tools
      nixfmt-classic
      notify-osd
      obsidian
      vlc
      # warp-terminal
      yubikey-manager
    ];
  };

  xdg.desktopEntries = {
    filen = {
      name = "Filen";
      genericName = "File Syncer";
      exec = "filen";
      terminal = false;
      categories = [ "Application" "Network" ];
    };
  };
}