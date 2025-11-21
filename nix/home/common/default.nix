{ config, pkgs, ... }:
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
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    defaultSopsFile = ../../../secrets/secrets-enc.yaml;
    defaultSopsFormat = "yaml";
  };
}
