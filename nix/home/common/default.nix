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
      libsecret
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
