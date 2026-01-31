{
  config,
  pkgs,
  ...
}:
let
  settings = config.sysconf.settings;
in
{
  # linux kernel
  # boot.kernelPackages = pkgs.linuxPackages_6_13; # need this to support the Realtek 2.5G NIC
  # boot.supportedFilesystems.zfs = lib.mkForce false; # this is because zfs kernel modules are usually behind and don't compile with the newer kernels.
  boot.supportedFilesystems = [ "btrfs" ];
  services.btrfs.autoScrub.enable = true;

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  sops.secrets."users/nelly/password".neededForUsers = true;
  sops.secrets."sshkeys/btrbk/ruca" = {
    owner = "root";
    group = "root";
    mode = "0600";
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
    services.btrbk = {
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
  services.printing = {
    enable = true;
    # Add Brother printer drivers
    drivers = [
      pkgs.brlaser
    ];
    # logLevel = "debug";
  };

  # Bluetooth (for wireless keyboards, mice, etc.)
  hardware.bluetooth.enable = true;
  services.blueman.enable = true;

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

  # Persistent network interface naming
  systemd.network.links."10-lan" = {
    matchConfig.MACAddress = "10:ff:e0:83:15:15";
    linkConfig.Name = "eth0";
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
      eth0 = {
        connection = {
          id = "eth0";
          type = "ethernet";
          interface-name = "eth0";
        };
        ipv4 = {
          method = "manual";
          address1 = "10.42.40.27/24,10.42.40.1";
          dns = builtins.concatStringsSep ";" config.sysconf.settings.dnsServers;
        };
        ipv6.method = "disabled";
      };
    };
  };

  # state version
  system.stateVersion = "24.11"; # Don't touch
}
