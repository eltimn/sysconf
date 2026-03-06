{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}:
{
  imports = [
    ./containers
    ./programs
    ./scripts
    ./services
  ];

  options.sysconf.settings = {
    secretCipherPath = lib.mkOption {
      type = lib.types.path;
      description = "Path to the secret-cipher directory.";
      default = "${config.home.homeDirectory}/secret-cipher";
    };
  };

  config = {
    home.packages = with pkgs; [
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
      nix-prefetch-git
      nushell
      pgcli
      podman-tui
      shellcheck
      # tmux
      # tmuxinator
      # trash-cli
      xclip
    ];

    sops = {
      age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";
      age.sshKeyPaths = [ "${config.home.homeDirectory}/.ssh/id_ed25519" ];
      defaultSopsFile = "${osConfig.sysconf.system.sops.secretsPath}/secrets-enc.yaml";
      defaultSopsFormat = "yaml";
    };

    # enable some modules
    sysconf.programs = {
      bat.enable = true;
      direnv.enable = true;
      git.enable = true;
      tmux.enable = true;
      tv.enable = true;
      zellij.enable = true;
      zsh.enable = true;
    };
  };
}
