{ pkgs, ... }:
{
  home = {
    # List of files to be symlinked into the user home directory.
    file.".ackrc".source = ./files/.ackrc;
    file.".ansible.cfg".source = ./files/.ansible.cfg;
    file.".gitignore".source = ./files/.gitignore;
    file.".mongoshrc.js".source = ./files/.mongoshrc.js;

    # file."bin".source = ./files/bin;
    # file."bin/common".source = ./files/bin;

    # links individual files
    file."bin/common" = {
      source = ./files/bin;
      recursive = true;
    };

    packages = with pkgs; [
      # ack-grep
      bitwarden-cli
      dnsutils
      gh
      git
      htop
      neovim
      sshfs
      tldr
      # tmux
      # tmuxinator
      # trash-cli
      xclip
    ];
  };
}
