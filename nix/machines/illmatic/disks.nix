{
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  swapDevices = [
    { device = "/dev/disk/by-label/swap"; }
  ];

  # zfs configuration
  boot.zfs.devNodes = "/dev/disk/by-id"; # needed because pools were created using disk ids.
  boot.zfs.extraPools = [
    "mediapool"
  ];

  # existing zfs disks
  fileSystems."/mnt/backup" = {
    device = "mediapool/backup";
    fsType = "zfs";
  };

  fileSystems."/mnt/files" = {
    device = "mediapool/files";
    fsType = "zfs";
  };

  fileSystems."/mnt/mobile" = {
    device = "mediapool/mobile";
    fsType = "zfs";
  };

  fileSystems."/mnt/music" = {
    device = "mediapool/music";
    fsType = "zfs";
  };

  fileSystems."/mnt/pictures" = {
    device = "mediapool/pictures";
    fsType = "zfs";
  };

  fileSystems."/mnt/plex" = {
    device = "mediapool/plex";
    fsType = "zfs";
  };

  fileSystems."/mnt/video" = {
    device = "mediapool/video";
    fsType = "zfs";
  };

  fileSystems."/mnt/channels" = {
    device = "mediapool/channels";
    fsType = "zfs";
  };

  fileSystems."/mnt/comedy" = {
    device = "mediapool/comedy";
    fsType = "zfs";
  };

  fileSystems."/mnt/movies" = {
    device = "mediapool/movies";
    fsType = "zfs";
  };

  fileSystems."/mnt/tv" = {
    device = "mediapool/tv";
    fsType = "zfs";
  };

  fileSystems."/mnt/videos" = {
    device = "mediapool/videos";
    fsType = "zfs";
  };
}
