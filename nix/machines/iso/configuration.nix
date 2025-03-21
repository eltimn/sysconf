{
  lib,
  pkgs,
  sshKeys,
  ...
}:
let
  runInstall = pkgs.writeShellScriptBin "run-install" (builtins.readFile ./scripts/run-install);
in
{
  # linux kernel
  boot.kernelPackages = pkgs.linuxPackages_6_13;
  boot.supportedFilesystems.zfs = lib.mkForce false;

  # gnome power settings do not turn off screen
  systemd = {
    targets = {
      sleep.enable = false;
      suspend.enable = false;
      hibernate.enable = false;
      hybrid-sleep.enable = false;
    };
  };

  environment.systemPackages = with pkgs; [
    git
    gum
    neovim
    runInstall
  ];

  users.users = {
    nixos = {
      openssh.authorizedKeys.keys = [
        sshKeys.lappy
        sshKeys.ruca
      ];
      # shell = pkgs.zsh;
    };
  };
}
