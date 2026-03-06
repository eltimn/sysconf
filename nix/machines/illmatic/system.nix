{
  config,
  pkgs,
  ...
}:
let
  inherit (config.sysconf) settings;
  consts = import ../../constants.nix;
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

    # Route gateway admin web thru caddy to avoid ssl cert warnings
    caddy.virtualHosts."unifi.${settings.homeDomain}".extraConfig = ''
      reverse_proxy https://router.${settings.homeDomain} {
        transport http {
          tls_insecure_skip_verify # unifi uses self-signed certs
        }
      }
    '';
  };

  # authorized ssh keys for btrbk
  users.users."root".openssh.authorizedKeys.keys = [
    settings.sshKeys.btrbk.ruca
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    borgbackup
    ffmpeg
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
      blocky = {
        enable = true;
        listenAddresses = [
          consts.networks.home.illmatic
          "127.0.0.1"
        ];
      };
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

      searxng = {
        enable = true;
        port = 8888;
      };
    };
  };

  # Ensure immich waits for the pictures mount
  systemd = {
    tmpfiles.rules = [
      "z /mnt/files 0755 nelly users -" # z updates user:group
      "d /mnt/files/Audio 0755 nelly users -"
      "d /mnt/files/Camera 0755 nelly users -"
      "d /mnt/files/Documents 0755 nelly users -"
      "d /mnt/files/Notes 0755 nelly users -"
      "d /mnt/files/secret-cipher 0755 nelly users -"
    ];

    network = {
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
        address = [ "${consts.networks.home.illmatic}/24" ];
        gateway = [ consts.networks.home.gateway ];
        dns = config.sysconf.settings.dnsServers;
        linkConfig.RequiredForOnline = "routable";
      };
    };

    services = {
      immich-server = {
        after = [ "mnt-pictures.mount" ];
        requires = [ "mnt-pictures.mount" ];
      };

      # Disable stock ZFS import service and create a bare import that doesn't load keys
      # The encrypted dataset will be manually unlocked via zfs-vault after Colmena deploys the key
      zfs-import-mediapool.enable = false;

      # Custom pool import that runs without loading encryption keys
      # This replaces the auto-generated service from boot.zfs.extraPools
      import-mediapool-bare = {
        description = "Import ZFS pool 'mediapool' (without key loading)";
        wantedBy = [
          "zfs-mount.service"
          "local-fs.target"
        ];
        after = [
          "systemd-modules-load.service"
          "systemd-udevd.service"
          "zfs-import.target"
        ];
        before = [
          "zfs-mount.service"
          "local-fs.target"
        ];

        serviceConfig = {
          Type = "oneshot";
          RemainAfterExit = true;
          Restart = "on-failure";
          RestartSec = "1s";
        };

        script = ''
          # Import the pool if not already imported
          if ! ${pkgs.zfs}/bin/zpool list mediapool >/dev/null 2>&1; then
            echo "Importing mediapool..."
            ${pkgs.zfs}/bin/zpool import -f -N -d /dev/disk/by-id mediapool
            echo "Pool imported successfully."
          else
            echo "Pool mediapool already imported."
          fi
        '';
      };
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
