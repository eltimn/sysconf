{
  ## Boot partition ##
  fileSystems."/boot" = {
    device = "/dev/disk/by-partlabel/boot";
    fsType = "vfat";
    options = [ "umask=0077" ];
  };

  ## Main system disk ##
  fileSystems."/mnt/btr_main" = {
    device = "/dev/disk/by-partlabel/disk-main-root";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "subvolid=5"
    ];
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

  ## Data disk ##
  fileSystems."/mnt/btr_data" = {
    device = "/dev/disk/by-label/data";
    fsType = "btrfs";
    options = [
      "compress=zstd"
      "noatime"
      "subvolid=5"
    ];
  };
}
