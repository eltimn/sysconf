{ config, ... }:
let
  settings = config.sysconf.settings;
  consts = import ../../constants.nix;
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
      blocky = {
        enable = true;
        listenAddresses = [
          consts.networks.home.cbox
          "127.0.0.1"
        ];
      };
    };
  };

  systemd.network = {
    # Persistent network interface naming
    links."10-lan" = {
      matchConfig.MACAddress = "d8:c4:97:3a:59:1a";
      linkConfig.Name = "eth0";
    };

    # Use systemd-networkd for network management
    enable = true;

    # Configure static IP with systemd-networkd
    networks."10-eth0" = {
      matchConfig.Name = "eth0";
      address = [ "${consts.networks.home.cbox}/24" ];
      gateway = [ consts.networks.home.gateway ];
      dns = config.sysconf.settings.dnsServers;
      linkConfig.RequiredForOnline = "routable";
    };
  };

  networking = {
    hostName = "cbox";
    useDHCP = false;
    useNetworkd = true;
    search = [ settings.homeDomain ];
    enableIPv6 = false;
    # Keep global nameservers so systemd-resolved always uses local DNS.
    nameservers = config.sysconf.settings.dnsServers;
  };

  # system
  system.stateVersion = "23.11"; # Don't change unless installing fresh
}
