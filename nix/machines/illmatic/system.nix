{
  config,
  pkgs,
  ...
}:
let
  settings = config.sysconf.settings;
in
{
  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Enable ZFS support
  # https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
  # https://nixos.org/manual/nixos/stable/options.html#opt-networking.hostId
  boot.supportedFilesystems = [
    "zfs"
    "ext4"
  ];

  boot.zfs.forceImportRoot = false;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    borgbackup
    sqlite
    config.services.forgejo.package
  ];

  # Enable services
  services = {
    zfs.autoScrub.enable = true;
  };

  # sysconf config
  sysconf = {
    users = {
      nelly = {
        enable = true;
        hashedPasswordFile = "/run/keys/nelly-password";
      };
      sysconf.enable = true;
      backup.enable = true;
    };

    containers = {
      channels-dvr.enable = true;
    };

    services = {
      blocky.enable = true;
      caddy.enable = true;
      immich.enable = true;
      jellyfin.enable = true;
      notify.enable = true;
      pocketid.enable = true;
      pocketid-backup.enable = true;

      forgejo = {
        enable = true;
        port = 8083;
      };

      forgejo-backup.enable = true;

      ntfy = {
        enable = true;
        port = 8082;
      };
    };
  };

  # Persistent network interface naming
  systemd.network.links."10-lan" = {
    matchConfig.MACAddress = "0c:c4:7a:db:ed:c3";
    linkConfig.Name = "eth3";
  };

  # Use systemd-networkd for network management
  systemd.network.enable = true;
  networking = {
    hostName = "illmatic";
    hostId = "60a48c03"; # Unique among my machines. Generated with: `head -c 4 /dev/urandom | sha256sum | cut -c1-8`
    useDHCP = false;
    useNetworkd = true;
    search = [ settings.homeDomain ];
    enableIPv6 = false;
    # Keep global nameservers so systemd-resolved always uses local DNS.
    nameservers = config.sysconf.settings.dnsServers;
  };

  # Configure static IP with systemd-networkd
  systemd.network.networks."10-eth3" = {
    matchConfig.Name = "eth3";
    address = [ "10.42.10.22/24" ];
    gateway = [ "10.42.10.1" ];
    dns = config.sysconf.settings.dnsServers;
    linkConfig.RequiredForOnline = "routable";
  };

  ## system
  system.stateVersion = "25.11"; # Don't touch unless installing a new system
}
