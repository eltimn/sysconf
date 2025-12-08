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

  sops = {
    age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];
    defaultSopsFile = ../../../secrets/secrets-enc.yaml;
    defaultSopsFormat = "yaml";
  };
}
