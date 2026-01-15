{
  config,
  pkgs,
  ...
}:
let
  nellyKeys = config.sysconf.settings.sshKeys.nelly;
  mountDisks = pkgs.writeShellScriptBin "mount-disks" (builtins.readFile ./scripts/mount-disks);
  prepareKey = pkgs.writeShellScriptBin "prepare-key" (builtins.readFile ./scripts/prepare-key);
  runInstall = pkgs.writeShellScriptBin "run-install" (builtins.readFile ./scripts/run-install);
in
{
  # linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_13;
  # boot.supportedFilesystems.zfs = lib.mkForce false;

  # gnome power settings do not turn off screen
  systemd = {
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  programs.gnupg.agent.enable = true;

  environment.systemPackages = with pkgs; [
    git
    gum
    neovim
    sops
    tmux
    mountDisks
    prepareKey
    runInstall
  ];

  users.users = {
    nixos = {
      openssh.authorizedKeys.keys = nellyKeys.base;
      shell = pkgs.bash;
    };
  };
}
