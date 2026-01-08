{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    ../../modules/system
    ../../modules/system/users/sysconf.nix
    ../../modules/system/containers/nginx.nix
  ];

  # Basic system configuration
  system.stateVersion = "25.11";

  # Networking - Digital Ocean will configure this
  networking.useDHCP = lib.mkForce true;

  # Boot loader - Digital Ocean handles this
  boot.loader.grub.enable = false;

  # Filesystem - Digital Ocean image
  fileSystems."/" = {
    device = "/dev/vda1";
    fsType = "ext4";
  };

  # User configuration
  users.users.nelly = {
    isNormalUser = true;
    description = "Tim N";
    extraGroups = [
      "networkmanager"
      "wheel"
    ];
    openssh.authorizedKeys.keys = config.sysconf.settings.primaryUserSshKeys;
    shell = pkgs.zsh;
    hashedPasswordFile = "/run/keys/nelly-password";
  };

  users.mutableUsers = false;

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # SSH configuration
  services.openssh = {
    enable = true;
    settings = {
      PermitRootLogin = "no";
      PasswordAuthentication = false;
    };
  };

  # Firewall
  networking.firewall.enable = true;
  networking.firewall.allowedTCPPorts = [ 22 ];

  # Enable Nginx container
  sysconf.containers.nginx.enable = true;
}
