# Illmatic

## Disks

- ZFS mediapool (sdb, sdd) 8TB mirrored mounts are in `/mnt`
- BTRFS datapool (sda, sdc) 2TB mirrored mounts are in `/srv/data`.
- ZFS encrypted dataset "mediapool/private" gets mounted at `/srv/media/private`
  via `zfs-vault` script. Used to store archives and backup files for services.
