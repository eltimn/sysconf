{ pkgs, ... }:
let filen = (pkgs.callPackage ./pkgs/filen.nix { });
in {
  home = {
    packages = with pkgs; [
      # ack-grep
      bitwarden-cli
      bitwarden-desktop
      caligula
      # devbox
      dnsutils
      # dropbox
      enpass
      # entr
      ffmpeg
      filen
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
      sshfs
      tldr
      # tmux
      # tmuxinator
      # trash-cli
      vlc
      # warp-terminal
      xclip
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