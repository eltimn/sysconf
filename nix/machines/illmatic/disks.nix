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
    "datapool"
    "mediapool"
  ];

  # existing zfs disks
  fileSystems."/mnt/backup" = {
    device = "datapool/backup";
    fsType = "zfs";
  };

  fileSystems."/mnt/files" = {
    device = "datapool/files";
    fsType = "zfs";
  };

  fileSystems."/mnt/mobile" = {
    device = "datapool/mobile";
    fsType = "zfs";
  };

  fileSystems."/mnt/music" = {
    device = "datapool/music";
    fsType = "zfs";
  };

  fileSystems."/mnt/pictures" = {
    device = "datapool/pictures";
    fsType = "zfs";
  };

  fileSystems."/mnt/plex" = {
    device = "datapool/plex";
    fsType = "zfs";
  };

  fileSystems."/mnt/video" = {
    device = "datapool/video";
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
