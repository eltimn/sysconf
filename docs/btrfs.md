# btrfs

Always mount each disk at the top level (subvolid=5) so it's easier to manage subvolumes and understand what's going on. If you also mount subvolumes elswhere the data will be available in both places and update both places.

On Ruca these are:

```nix
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
```

## Add New Subvolume

## Add New Subvolume to either drive
1. Create the subvolume:
```bash
sudo btrfs subvolume create /mnt/btr_main/@newsubvol # (replace with your name)
```
2. Update NixOS config to mount it (e.g., at /srv/data/newmount), then nixos-rebuild switch.
