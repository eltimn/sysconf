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

    services = {
      blocky.enable = true;
    };
  };

  # Persistent network interface naming
  systemd.network.links."10-lan" = {
    matchConfig.MACAddress = "d8:c4:97:3a:59:1a";
    linkConfig.Name = "eth0";
  };

  # Use systemd-networkd for network management
  systemd.network.enable = true;
  networking = {
    hostName = "cbox";
    useDHCP = false;
    useNetworkd = true;
    search = [ settings.homeDomain ];
    enableIPv6 = false;
    # Keep global nameservers so systemd-resolved always uses local DNS.
    nameservers = config.sysconf.settings.dnsServers;
  };

  # Configure static IP with systemd-networkd
  systemd.network.networks."10-eth0" = {
    matchConfig.Name = "eth0";
    address = [ "10.42.10.23/24" ];
    gateway = [ "10.42.10.1" ];
    dns = config.sysconf.settings.dnsServers;
    linkConfig.RequiredForOnline = "routable";
  };

  # system
  system.stateVersion = "23.11"; # Don't change unless installing fresh
}
