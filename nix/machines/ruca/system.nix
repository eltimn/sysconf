{
  config,
  pkgs,
  ...
}:
let
  settings = config.sysconf.settings;
  staticIP = "10.42.40.27";
in
{
  # linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_13; # need this to support the Realtek 2.5G NIC
  # boot.supportedFilesystems.zfs = lib.mkForce false; # this is because zfs kernel modules are usually behind and don't compile with the newer kernels.
  boot = {
    supportedFilesystems = [ "btrfs" ];

    # Bootloader
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };

  sops.secrets = {
    "users/nelly/password".neededForUsers = true;
    "sshkeys/btrbk/ruca" = {
      owner = "root";
      group = "root";
      mode = "0600";
    };
    "caddy-env" = {
      format = "dotenv";
      sopsFile = "${config.sysconf.system.sops.secretsPath}/caddy-enc.env";
      key = "";
      owner = config.users.users.caddy.name;
      group = config.users.users.caddy.group;
      mode = "0400";
    };
    "incus/pocketid_client_id" = {
      owner = "root";
      group = "root";
      mode = "0600";
    };
  };

  sysconf = {
    settings.hostRole = "desktop";
    settings.desktopEnvironment = "cosmic";

    users.nelly = {
      enable = true;
      hashedPasswordFile = config.sops.secrets."users/nelly/password".path;
      envEditor = "zeditor --wait";
    };

    # BTRFS snapshots for home directory
    services = {
      btrbk = {
        enable = true;
        configFile = ''
          # Enable transaction logging
          transaction_log            /var/log/btrbk.log
          # Use a lockfile so only one btrbk instance can run at a time
          lockfile                   /run/lock/btrbk.lock
          # Enable stream buffering
          stream_buffer              256m

          # Store snapshots under /snapshots under the root of the volume
          snapshot_dir               @snapshots
          # Only create new snapshots when changes have been made
          snapshot_create            onchange
          # Preserve hourly snapshots for up to 48 hours, and daily snapshots for up to 14 days
          snapshot_preserve          48h 14d 0w 0m 0y
          # The latest snapshot is always kept, regardless of the preservation policy
          snapshot_preserve_min      latest

          # Preserve daily backups for up to 21 days, weekly backups for up to 6 weeks, monthly backups for up to 3 months, and yearly backups for up to a year
          target_preserve            0h 21d 6w 3m 1y
          # Preserve the latest snapshot, regardless of the preservation policy
          target_preserve_min        latest

          # Preserve one archive of each type except hourly backups
          archive_preserve           0h 1d 1w 1m 1y
          archive_preserve_min       latest

          # ssh
          ssh_identity ${config.sops.secrets."sshkeys/btrbk/ruca".path}
          ssh_user root

          # things to snapshot
          volume /mnt/btr-main
            subvolume @home
              target /srv/data/snapshots-main
              target ssh://nas.home.eltimn.com/srv/data/snapshots-ruca
        '';
      };

      caddy = {
        enable = true;
        environmentFile = config.sops.secrets."caddy-env".path;
      };

      incus = {
        enable = true;
        oidcClientIdFile = config.sops.secrets."incus/pocketid_client_id".path;
      };
    };

    # GNOME specific configuration
    # system.desktop.gnome = {
    #   videoDrivers = [ "amdgpu" ];
    # };
  };

  # graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  # Enable CUPS to print documents.
  # Bluetooth (for wireless keyboards, mice, etc.)

  hardware.bluetooth.enable = true;

  environment.systemPackages = with pkgs; [
    clinfo
    isd
    pciutils

    # Bluetooth CLI tools (e.g. bluetoothctl)
    bluez
    blueman
  ];

  # Enable nix-ld for running dynamically linked executables
  # This allows running binaries from npm packages (like @github/copilot) that expect standard Linux library locations
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      # Additional libraries can be added here if needed
      stdenv.cc.cc.lib
    ];
  };

  programs.gnupg.agent.enable = true;

  # Needed for yubikey
  services.pcscd.enable = true;

  services = {
    btrfs.autoScrub.enable = true;
    printing = {
      enable = true;
      # Add Brother printer drivers
      drivers = [
        pkgs.brlaser
      ];
      # logLevel = "debug";
    };

    blueman.enable = true;
  };

  # Persistent network interface naming
  systemd = {
    network.links."10-lan" = {
      matchConfig.MACAddress = "10:ff:e0:83:15:15";
      linkConfig.Name = "eth0";
    };

    tmpfiles.rules = [
      "d /srv/ext/nelly 0750 nelly users -"
    ];
  };

  # networking
  networking = {
    hostName = "ruca";
    useDHCP = false; # NetworkManager handles this, but just to make sure.
    search = [ settings.homeDomain ];
    networkmanager.enable = true;
    enableIPv6 = false;

    # Static IP configuration for NetworkManager
    networkmanager.ensureProfiles.profiles = {
      # The bridge profile
      br0 = {
        connection = {
          id = "br0";
          type = "bridge";
          interface-name = "br0";
        };
        bridge = {
          stp = false; # Fixes 30s delay / blocking
        };
        ethernet = {
          cloned-mac-address = "10:ff:e0:83:15:15"; # Use the physical MAC so the router accepts traffic
        };
        ipv4 = {
          method = "manual";
          address1 = "${staticIP}/24,10.42.40.1";
          dns = builtins.concatStringsSep ";" config.sysconf.settings.dnsServers;
        };
        ipv6.method = "disabled";
      };

      # The slave interface
      eth0 = {
        connection = {
          id = "eth0";
          type = "ethernet";
          interface-name = "eth0";
          master = "br0";
          slave-type = "bridge";
        };
        ethernet = {
          mac-address = "10:ff:e0:83:15:15"; # Ensure the physical card keeps its factory MAC
        };
      };
    };
  };

  # state version
  system.stateVersion = "24.11"; # Don't touch
}
