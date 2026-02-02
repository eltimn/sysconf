{
  fileSystems = {
    ## Boot partition ##
    "/boot" = {
      device = "/dev/disk/by-partlabel/boot";
      fsType = "vfat";
      options = [ "umask=0077" ];
    };

    ## Main system disk ##
    "/mnt/btr-main" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "btrfs";
      options = [
        "subvolid=5"
        "compress=zstd"
        "noatime"
      ];
    };

    # Root filesystem
    "/" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=@"
      ];
    };

    # Home subvolume
    "/home" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=@home"
      ];
    };

    # Nix subvolume
    "/nix" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=@nix"
      ];
    };

    # Log subvolume
    "/var/log" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=@log"
      ];
    };

    # Snapshots subvolume
    "/snapshots" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=@snapshots"
      ];
    };

    # Incus subvolume
    "/srv/main/incus" = {
      device = "/dev/disk/by-partlabel/disk-main-root";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=@incus"
      ];
    };

    ## Data disk ##
    "/mnt/btr-data" = {
      device = "/dev/disk/by-partlabel/data";
      fsType = "btrfs";
      options = [
        "subvolid=5"
        "compress=zstd"
        "noatime"
      ];
    };

    # Snapshots-main subvolume
    "/srv/data/snapshots-main" = {
      device = "/dev/disk/by-partlabel/data";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=@snapshots-main"
      ];
    };

    ## Ext partition ##
    "/srv/ext" = {
      device = "/dev/disk/by-partlabel/ext";
      fsType = "ext4";
    };
  };
}
