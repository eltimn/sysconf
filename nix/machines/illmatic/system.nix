{
  config,
  pkgs,
  ...
}:
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

      forgejo = {
        enable = true;
        port = 8083;
      };

      forgejo-backup = {
        enable = true;
        passwordPath = "/run/keys/borg-passphrase-illmatic";
      };

      ntfy = {
        enable = true;
        port = 8082;
      };
    };
  };

  networking = {
    hostName = "illmatic";
    hostId = "60a48c03"; # Unique among my machines. Generated with: `head -c 4 /dev/urandom | sha256sum | cut -c1-8`
    useDHCP = false;

    # Configure static IP on eth0
    interfaces."enp0s20f3" = {
      ipv4.addresses = [
        {
          address = "10.42.10.22";
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

  ## system
  system.stateVersion = "25.11"; # Don't touch unless installing a new system
}
