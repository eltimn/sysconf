{
  config,
  lib,
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
  # Make initrd extra tolerant of USB/Ventoy-style boot media.
  boot.initrd.availableKernelModules = lib.mkDefault [
    "xhci_pci"
    "ehci_pci"
    "uhci_hcd"
    "usb_storage"
    "uas"
    "sd_mod"
    "sr_mod"
  ];

  # Avoid early USB autosuspend issues on some firmware.
  boot.kernelParams = lib.mkDefault [ "usbcore.autosuspend=-1" ];

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
    zed-editor
  ];

  users.users = {
    nixos = {
      openssh.authorizedKeys.keys = nellyKeys.base;
      shell = pkgs.bash;
    };
  };
}
