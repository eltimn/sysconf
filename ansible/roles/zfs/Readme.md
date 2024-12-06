http://arstechnica.com/information-technology/2014/02/ars-walkthrough-using-the-zfs-next-gen-filesystem-on-linux/1/
http://www.jamescoyle.net/how-to/478-create-a-zfs-volume-on-ubuntu
http://serverascode.com/2014/07/01/zfs-ubuntu-trusty.html

The following commands were used to create zfs pools:

    sudo zpool create -f -o ashift=12 datapool mirror \
    /dev/disk/by-id/wwn-0x50014ee2b525ed29 \
    /dev/disk/by-id/wwn-0x50014ee20a660682

    sudo mkdir /mnt/movies
    sudo mkdir /mnt/videos

    # Make sure mountpoint directory exists and is empty
    sudo zfs create -o mountpoint=/mnt/music datapool/music
    sudo zfs create -o mountpoint=/mnt/video datapool/video
    sudo zfs create -o mountpoint=/mnt/backup datapool/backup
    sudo zfs create -o mountpoint=/mnt/tv datapool/tv
    sudo zfs create -o mountpoint=/mnt/camera datapool/camera
    sudo zfs create -o mountpoint=/mnt/pictures datapool/pictures
    sudo zfs create -o mountpoint=/mnt/dvr datapool/dvr
    sudo zfs create -o mountpoint=/mnt/plex datapool/plex
    sudo zfs create -o mountpoint=/mnt/dvr-config datapool/dvr-config
    sudo zfs create -o mountpoint=/mnt/dvr-recordings datapool/dvr-recordings
    sudo zfs create -o mountpoint=/mnt/movies datapool/movies
    sudo zfs create -o mountpoint=/mnt/videos datapool/videos

    sudo chown nelly:nelly /mnt/backup
    sudo chown nelly:nelly /mnt/music
    sudo chown nelly:nelly /mnt/video
    sudo chown nelly:nelly /mnt/tv
    sudo chown nelly:nelly /mnt/camera
    sudo chown nelly:nelly /mnt/pictures
    sudo chown nelly:nelly /mnt/dvr
    sudo chown plex:plex /mnt/plex
    sudo chown channels:channels /mnt/dvr-config
    sudo chown channels:channels /mnt/dvr-recordings
    #sudo chmod g+w /mnt/tv
    sudo chown nelly:nelly /mnt/movies
    sudo chown nelly:nelly /mnt/videos

List disk usage:

    sudo zfs list

Destroy a pool:

    sudo zfs destroy datapool/unifi

Create a snapshot:

    sudo zfs snapshot datapool/backup@snapshot1

List snapshots:

    sudo zfs list -rt snapshot

Delete a snapshot:

    sudo zfs destroy datapool/backup@snapshot1
