{
  lib,
  ...
}:

{
  imports = [
    ../../modules/system
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

  sysconf = {
    users = {
      nelly = {
        enable = true;
        hashedPasswordFile = "/run/keys/nelly-password";
      };
      sysconf.enable = true;
    };
  };

  # Enable Nginx container
  sysconf.containers.nginx.enable = true;
}
