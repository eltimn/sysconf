# btrfs

Mount each disk at the top level (subvolid=5) so it's easier to manage subvolumes and is recommended by btrbk. If you also mount subvolumes elsewhere the data will be available in both places and update both places.

On Ruca these are:

```nix
## Main system disk ##
fileSystems."/mnt/btr-main" = {
  device = "/dev/disk/by-partlabel/disk-main-root";
  fsType = "btrfs";
  options = [
    "compress=zstd"
    "noatime"
    "subvolid=5"
  ];
};

## Data disk ##
fileSystems."/mnt/btr-data" = {
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

1. Mount the disk at the top level  (subvolid=5) if not already.
```shell
sudo mkdir -p /mnt/btrtmp
sudo mount -o compress=zstd,noatime,subvolid=5 /dev/nvme0n1p2 /mnt/btrtmp
```

2. Create the subvolume:
```shell
sudo btrfs subvolume create /mnt/btr-main/@newsubvol # (replace with your name)
```

3. Update NixOS config to mount it (e.g., at /srv/data/newmount), then nixos-rebuild switch.
```nix
fileSystems."/srv/data/newvol" = {
  device = "/dev/disk/by-partlabel/disk-main-root";
  fsType = "btrfs";
  options = [
    "compress=zstd"
    "noatime"
    "subvol=@newsubvol"
  ];
};
```

4. Cleanup if necessary
```shell
sudo umount /mnt/btrtmp
sudo rmdir /mnt/btrtmp
```

## btrbk

Create SSH key pair:
```shell
mkdir -p /etc/btrbk/ssh
ssh-keygen -t ed25519 -f /etc/btrbk/ssh/id_ed25519 -C btrbk@ruca -N ""
```

## Resources
[NixOS Wiki](https://wiki.nixos.org/wiki/Btrfs)
[Arch Wiki](https://wiki.archlinux.org/title/Btrfs)
[btrbk](https://github.com/digint/btrbk)


## Conversion from zfs on illmatic

Based on the lsblk output, the drives for the datapool are sda and sdc. Here are the commands to convert them to a Btrfs mirror.
I have used the disk IDs derived from your lsblk output (Model + Serial) to ensure we target the correct physical disks (WD Red 2TB drives) and avoid touching the 8TB mediapool drives.

1. Define Variables & Verify

Run this to set the variables and verify they point to the correct 1.8T WD drives.
```shell
# Define the drives based on Serial Numbers
DISK1="/dev/disk/by-id/ata-WDC_WD20EFRX-68EUZN0_WD-WCC4MM967PLX"
DISK2="/dev/disk/by-id/ata-WDC_WD20EFRX-68EUZN0_WD-WCC4MLC96D2Z"
# Verify - Ensure these point to sda and sdc (or whatever they are mapped to now)
ls -l $DISK1 $DISK2
```

2. Wipe Old ZFS Data

Destroy the pool and wipe the disks to remove all ZFS metadata and partitions.
```shell
# Destroy the pool if it's still imported
sudo zpool destroy datapool
# Wipe filesystem signatures
sudo wipefs -a $DISK1
sudo wipefs -a $DISK2
# Zap the partition table to clear everything
sudo sgdisk --zap-all $DISK1
sudo sgdisk --zap-all $DISK2
```

3. Create Btrfs Mirror

Format the drives as a RAID1 Btrfs array.
```shell
# Create Btrfs RAID1 (Data and Metadata mirrored)
sudo mkfs.btrfs -L data -d raid1 -m raid1 $DISK1 $DISK2
```

4. Verification

Confirm the array is created correctly.
```shell
sudo btrfs filesystem show /dev/disk/by-label/data
```
