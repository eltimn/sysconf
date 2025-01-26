{ pkgs, ... }:
{
  home = {
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
