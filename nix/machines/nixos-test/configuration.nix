{
  config,
  lib,
  pkgs,
  ...
}:

{
  imports = [
    # Include common configuration
    # ../../system/default.nix
    ../../system/containers/rootless.nix
    ../../system/containers/nginx.nix
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
  users.users.sysconf = {
    isSystemUser = true;
    description = "System Configuration Manager";
    group = "sysconf";
    extraGroups = [
      "wheel"
      "networkmanager"
    ];
    shell = pkgs.bash;
    openssh.authorizedKeys.keys = config.sysconf.settings.primaryUserSshKeys;
  };

  users.groups.sysconf = { };

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

  # Enable zsh
  programs.zsh.enable = true;

  # Passwordless sudo for sysconf (req'd by Colmena)
  security.sudo.extraRules = [
    {
      users = [ "sysconf" ];
      commands = [
        {
          command = "ALL";
          options = [ "NOPASSWD" ];
        }
      ];
    }
  ];

  # Enable flakes
  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];
  nix.settings.trusted-users = [
    "root"
    "sysconf"
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

  # Essential packages
  environment.systemPackages = with pkgs; [
    git
  ];
}
