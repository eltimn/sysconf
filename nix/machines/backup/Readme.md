# backup server

## Debian 12

### Create user and add to sudo group

```shell
adduser nelly
usermod -aG sudo nelly
```

### Add SSH key
``` shell
# need to figure out how to login as root or login as nelly with password to add key for nelly user.
ssh-copy-id -i ~/.ssh/id_ed25519.pub nelly@backup.eltimn.com
# do it manually
mkdir ~/.ssh
chmod 0700 ~/.ssh
touch ~/.ssh/authorized_keys
chmod 0600 ~/.ssh/authorized_keys
vim ~/.ssh/authorized_keys # paste in your public key
```

## Format storage drive

[how-to-format-disk-in-linux](https://linuxconfig.org/how-to-format-disk-in-linux)

### Helpers

```shell
sudo fdisk -l               # list all of the disks
df -hT                      # see all mounted drives's usage
sudo mount -a               # mount all drives in fstab
sudo umount /dev/sdX1       # unmount the drive
```

### Partition disk:

```shell
sudo gdisk /dev/sdX
Command (? for help): n
(then use all defaults)
Command (? for help): w
```
### Format the drive

```shell
sudo mkfs -t ext4 /dev/sdX1
```

### Mount the drive
```shell
# Prepare backup directory
sudo mkdir -p /mnt/backup

# Get the UUID of the new partition
lsblk -d -fs /dev/sdX1

# add the following to fstab
UUID=80b496fa-ce2d-4dcf-9afc-bcaa731a67f1  /mnt/backup  ext4  defaults  0  2
```
