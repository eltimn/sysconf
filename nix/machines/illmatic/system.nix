{
  config,
  pkgs,
  ...
}:
let
  settings = config.sysconf.settings;
in
{
  boot = {
    # Bootloader
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;

    # Enable ZFS support
    # https://openzfs.github.io/openzfs-docs/Getting%20Started/NixOS/index.html
    # https://nixos.org/manual/nixos/stable/options.html#opt-networking.hostId
    supportedFilesystems = [
      "btrfs"
      "zfs"
      "ext4"
    ];

    zfs.forceImportRoot = false;
  };

  # Enable services
  services = {
    btrfs.autoScrub.enable = true;
    zfs.autoScrub.enable = true;
  };

  # authorized ssh keys for btrbk
  users.users."root".openssh.authorizedKeys.keys = [
    settings.sshKeys.btrbk.ruca
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    borgbackup
    sqlite
    config.services.forgejo.package
  ];

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

  # Ensure immich waits for the pictures mount
  systemd.services.immich-server = {
    after = [ "mnt-pictures.mount" ];
    requires = [ "mnt-pictures.mount" ];
  };

  systemd.network = {
    # Persistent network interface naming
    links."10-lan" = {
      matchConfig.MACAddress = "0c:c4:7a:db:ed:c3";
      linkConfig.Name = "eth3";
    };

    # Use systemd-networkd for network management
    enable = true;

    # Configure static IP with systemd-networkd
    networks."10-eth3" = {
      matchConfig.Name = "eth3";
      address = [ "10.42.10.22/24" ];
      gateway = [ "10.42.10.1" ];
      dns = config.sysconf.settings.dnsServers;
      linkConfig.RequiredForOnline = "routable";
    };
  };

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

  ## system
  system.stateVersion = "25.11"; # Don't touch unless installing a new system
}
