{ config, pkgs, ... }:
{
  home = {
    packages = with pkgs; [
      # ack-grep
      bitwarden-cli
      doctl
      dust # better `du`
      fastfetch
      fd
      gh
      git
      gnumake
      gocryptfs
      libsecret
      mongodb-tools
      mongosh
      neovim
      nushell
      podman-tui
      shellcheck
      # tmux
      # tmuxinator
      # trash-cli
      xclip
    ];
  };

  sops = {
    age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
    defaultSopsFile = ../../../../secrets/secrets-enc.yaml;
    defaultSopsFormat = "yaml";
  };
}
