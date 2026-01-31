{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-label/nixos";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-label/boot";
      fsType = "vfat";
    };

    # existing zfs disks
    "/mnt/backup" = {
      device = "mediapool/backup";
      fsType = "zfs";
    };

    "/mnt/files" = {
      device = "mediapool/files";
      fsType = "zfs";
    };

    "/mnt/mobile" = {
      device = "mediapool/mobile";
      fsType = "zfs";
    };

    "/mnt/music" = {
      device = "mediapool/music";
      fsType = "zfs";
    };

    "/mnt/pictures" = {
      device = "mediapool/pictures";
      fsType = "zfs";
    };

    "/mnt/plex" = {
      device = "mediapool/plex";
      fsType = "zfs";
    };

    "/mnt/video" = {
      device = "mediapool/video";
      fsType = "zfs";
    };

    "/mnt/channels" = {
      device = "mediapool/channels";
      fsType = "zfs";
    };

    "/mnt/comedy" = {
      device = "mediapool/comedy";
      fsType = "zfs";
    };

    "/mnt/movies" = {
      device = "mediapool/movies";
      fsType = "zfs";
    };

    "/mnt/tv" = {
      device = "mediapool/tv";
      fsType = "zfs";
    };

    "/mnt/videos" = {
      device = "mediapool/videos";
      fsType = "zfs";
    };

    ## Data disk mirror ##
    "/srv/data/snapshots-ruca" = {
      device = "/dev/disk/by-label/data";
      fsType = "btrfs";
      options = [
        "compress=zstd"
        "noatime"
        "subvol=@snapshots-ruca"
      ];
    };
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];

  # zfs configuration
  boot.zfs.devNodes = "/dev/disk/by-id"; # needed because pools were created using disk ids.
  boot.zfs.extraPools = [
    "mediapool"
  ];
}
