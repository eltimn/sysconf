{
  # Boot partition
  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/boot";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  # Root filesystem
  fileSystems."/" = {
    device = "/dev/disk/by-partlabel/disk-main-root";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "subvol=@"
    ];
  };

  # Home subvolume
  fileSystems."/home" = {
    device = "/dev/disk/by-partlabel/disk-main-root";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "subvol=@home"
    ];
  };

  # Nix subvolume
  fileSystems."/nix" = {
    device = "/dev/disk/by-partlabel/disk-main-root";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "subvol=@nix"
    ];
  };

  # Log subvolume
  fileSystems."/var/log" = {
    device = "/dev/disk/by-partlabel/disk-main-root";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "subvol=@log"
    ];
  };

  # Data disk (will be converted to btrfs later)
  fileSystems."/srv/data" = {
    device = "/dev/disk/by-label/data";
    fsType = "ext4";
    # fsType = "btrfs";
    # options = [
    #   "compress=zstd"
    #   "noatime"
    # ];
  };
}
