{ config, ... }:
let
  settings = config.sysconf.settings;
in
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  sysconf = {
    users = {
      nelly = {
        enable = true;
        hashedPasswordFile = "/run/keys/nelly-password";
      };
      sysconf.enable = true;
    };
  };

  networking = {
    hostName = "cbox";
    search = [ settings.homeDomain ];

    # Configure static IP on eth0
    interfaces."enp0s20f3" = {
      useDHCP = false;
      ipv4.addresses = [
        {
          address = "10.42.10.23";
          prefixLength = 24; # /24 subnet
        }
      ];
    };

    # Default gateway
    defaultGateway = {
      address = "10.42.10.1";
      interface = "enp0s20f3";
    };

    # DNS servers
    nameservers = config.sysconf.settings.dnsServers;

    # Optional: Disable IPv6 if not needed
    enableIPv6 = false;
  };

  # system
  system.stateVersion = "23.11"; # Don't change unless installing fresh
}
