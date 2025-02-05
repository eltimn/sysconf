{
  pkgs,
  sshKeys,
  ...
}:
let
  runInstall = pkgs.writeShellScriptBin "run-install" (builtins.readFile ./scripts/run-install);
in
{
  boot.kernelPackages = pkgs.linuxPackages_6_12;

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
