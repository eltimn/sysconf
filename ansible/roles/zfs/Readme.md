# ZFS

## Disks

    dev   serial           id                      brand   size
    sda   WD-WCC4MM967PLX  wwn-0x50014ee2b525ed29  WD Red  2TB
    sdb   VLJ90M5Y         wwn-0x5000cca260e048ab  HGST    8TB
    sdc   WD-WCC4MLC96D2Z  wwn-0x50014ee20a660682  WD Red  2TB
    sdd   VLJK0SEV         wwn-0x5000cca260e3ec27  HGST    8TB

```shell
lsblk --nodeps -o name,serial # list the serial numbers of all drives
ls -l /dev/disk/by-id         # find the disk id
```

## Notes

The following commands were used to create zfs pools and datasets:
    # datapool - 2 TB
    sudo zpool create -f -o ashift=12 datapool mirror \
    /dev/disk/by-id/wwn-0x50014ee2b525ed29 \
    /dev/disk/by-id/wwn-0x50014ee20a660682

    # media pool - 8 TB
    sudo zpool create -f -o ashift=12 mediapool mirror \
    /dev/disk/by-id/wwn-0x5000cca260e048ab \
    /dev/disk/by-id/wwn-0x5000cca260e3ec27

    sudo zfs create -o mountpoint=/mnt/backup datapool/backup
    sudo zfs create -o mountpoint=/mnt/mobile datapool/mobile
    sudo zfs create -o mountpoint=/mnt/music datapool/music
    sudo zfs create -o mountpoint=/mnt/pictures datapool/pictures
    sudo zfs create -o mountpoint=/mnt/plex datapool/plex
    sudo zfs create -o mountpoint=/mnt/video datapool/video

    sudo zfs create -o mountpoint=/mnt/channels mediapool/channels
    sudo zfs create -o mountpoint=/mnt/comedy mediapool/comedy
    sudo zfs create -o mountpoint=/mnt/movies mediapool/movies
    sudo zfs create -o mountpoint=/mnt/tv mediapool/tv
    sudo zfs create -o mountpoint=/mnt/videos mediapool/videos

    sudo chown nelly:nelly /mnt/backup
    sudo chown nelly:nelly /mnt/mobile
    sudo chown nelly:nelly /mnt/music
    sudo chown nelly:nelly /mnt/pictures
    sudo chown plex:plex /mnt/plex
    sudo chown nelly:nelly /mnt/video

    sudo chown nelly:nelly /mnt/channels
    sudo chown nelly:nelly /mnt/comedy
    sudo chown nelly:nelly /mnt/movies
    sudo chown nelly:nelly /mnt/tv
    sudo chown nelly:nelly /mnt/videos

List disk usage:

    sudo zfs list

Move a mount point:

    sudo zfs set mountpoint=/mnt/movies mediapool/movies

Destroy a pool:

    sudo zfs destroy datapool/unifi

Create a snapshot:

    sudo zfs snapshot datapool/backup@snapshot1

List snapshots:

    sudo zfs list -rt snapshot

Delete a snapshot:

    sudo zfs destroy datapool/backup@snapshot1

## Resources

* https://tadeubento.com/2024/aarons-zfs-guide-install-zfs-on-debian-gnu-linux/