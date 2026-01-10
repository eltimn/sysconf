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
  networking.hostId = "60a48c03"; # Unique among my machines. Generated with: `head -c 4 /dev/urandom | sha256sum | cut -c1-8`

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    borgbackup
    sqlite
    config.services.forgejo.package
  ];

  # Enable services
  services = {
    immich = {
      enable = true;
      port = 2283; # default is 2283
    };

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
      caddy = {
        enable = true;
        domain = "home.eltimn.com";
      };

      coredns = {
        enable = true;
      };

      jellyfin = {
        enable = true;
        # port = 8096;
      };

      ntfy = {
        enable = true;
        port = 8082;
        baseUrl = "https://ntfy.home.eltimn.com";
      };

      notify = {
        enable = true;
      };

      forgejo = {
        enable = true;
        port = 8083;
      };

      forgejo-backup = {
        enable = true;
        passwordPath = "/run/keys/borg-passphrase-illmatic";
      };
    };
  };

  ## system
  system.stateVersion = "25.11"; # Don't touch unless installing a new system
}
