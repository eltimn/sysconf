{ pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # ack-grep
      bitwarden-cli
      btop
      dnsutils
      dust # better `du`
      fastfetch
      fd
      gh
      git
      gnumake
      gocryptfs
      gum
      htop
      libsecret
      neovim
      nushell
      shellcheck
      sshfs
      stow
      tldr
      # tmux
      # tmuxinator
      # trash-cli
      xclip
    ];
  };
}
