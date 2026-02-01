# ZFS

## Taking Snapshots

```shell
sudo zfs snapshot mypool/mydataset@$(date +%Y%m%d-%H%M%S)
zfs list -t snapshot
```

## Creating new datasets (recommended)

Use legacy mounts so systemd/NixOS controls ordering and dependencies.

```shell
sudo zfs create datapool/<name>
sudo zfs set mountpoint=legacy datapool/<name>
```

Then add a `fileSystems` entry in `disks.nix`, keep pool roots with
`mountpoint=none` and `canmount=off`, ensure `boot.zfs.extraPools`
lists the pool, and set `networking.hostId`.

## Creating an encrypted parent dataset

The children will inherit the encryption settings from the parent.

```shell
# Encrypted parent dataset
sudo zfs create -o encryption=aes-256-gcm \
  -o keyformat=passphrase \
  -o keylocation=prompt \
  -o compression=zstd \
  -o mountpoint=/srv/media/private \
  mediapool/private

# Children datasets
sudo zfs create mediapool/private/archives
sudo zfs create mediapool/private/backup

# Manually unlock key and mount dataset and children
sudo zfs load-key -L "file://$KEY_FILE" mediapool/private
sudo zfs mount -R mediapool/private

# Manually unmount and unload key
sudo zfs unmount mediapool/private/archives
sudo zfs unmount mediapool/private/backup
sudo zfs unmount mediapool/private
sudo zfs unload-key mediapool/private
```

## Illmatic Conversion to NixOS

On Illmatic, the drives that were created on Ubuntu were converted for use with
NixOS. This involved:

1. A forced manual import `sudo zpool import -f datapool`.
2. Updated the `mountpoint` and `canmount` settings on each one, using code
   like:

```shell
# set mountpoint to none for the pool roots
sudo zfs set mountpoint=none datapool
sudo zfs set mountpoint=none mediapool
# set canmount to off for the pool roots
sudo zfs set canmount=off mediapool
sudo zfs set canmount=off datapool

# set mountpoint to legacy for all of the datasets
sudo zfs set mountpoint=legacy datapool/backup
sudo zfs set mountpoint=legacy datapool/mobile
...

# Update user:group of all files
sudo chown -R nelly:users /mnt/backup
sudo chown -R nelly:users /mnt/mobile
...
```

Mountpoints were set to legacy so that systemd will control when they are
mounted. This could be useful to ensure drives are mounted before a specific
service will start. The other option is to let zfs handle it.

```shell
$ zfs list \
	-o name,canmount,mountpoint -r datapool mediapool
NAME                CANMOUNT  MOUNTPOINT
datapool            off       none
datapool/backup     on        legacy
datapool/mobile     on        legacy
datapool/music      on        legacy
datapool/pictures   on        legacy
datapool/plex       on        legacy
datapool/stuff      on        legacy
datapool/video      on        legacy
mediapool           off       none
mediapool/channels  on        legacy
mediapool/comedy    on        legacy
mediapool/movies    on        legacy
mediapool/tv        on        legacy
mediapool/videos    on        legacy
```

**Error in logs:** Subject: systemd-udev-settle.service is deprecated.

[Issue/Hacky Fix](https://github.com/openzfs/zfs/issues/10891#issuecomment-3582856506)

## From Gemini 3 Pro (12/8/2025)

1. `boot.zfs.extraPools` vs. `fileSystems`

There are two ways to mount ZFS datasets.

- **Legacy Mounting (Recommended for NixOS):**
  - **How it works:** You set `mountpoint=legacy` on the ZFS dataset itself
    (using `zfs set`). Then, you define the mount in your disks.nix using
    fileSystems.
  - **Why:** This gives NixOS (via systemd) full control over when and how it
    mounts. It prevents race conditions where ZFS tries to mount it before the
    system is ready.
- **ZFS Auto-mounting:**
  - **How it works:** You set `mountpoint=/mnt/backup` on the dataset. ZFS tries
    to mount it automatically when the pool is imported.
  - **Why:** It's the "standard" ZFS way, but on NixOS, it **can** conflict with
    the declarative configuration.
  - **Conflict:** If you have both a ZFS `mountpoint` set (e.g., `/mnt/backup`)
    AND a `fileSystems` entry, both ZFS and systemd fight to mount it. This is
    why setting `mountpoint=legacy` is crucial if you use `fileSystems`.

2. `networking.hostId`
   The wiki emphasizes this. ZFS uses this ID to ensure two running systems
   don't try to import the same pool at the same time (which corrupts data).
   - **Your Config:** You already have this set in system.nix
     (`networking.hostId = "60a48c03"`). This is correct and necessary.

3. `boot.zfs.extraPools`
   - **What it does:** It tells NixOS "Hey, besides the root pool, please
     explicitly look for and import these other pools (`datapool`, `mediapool`)
     during boot."
   - **Why you need it:** Since your root filesystem is on `ext4` (not ZFS),
     NixOS won't automatically look for ZFS pools unless you tell it to.

> What if I removed the fileSystems entries and just used zfs automounting? Any reason not to do that?

You can do that, and it is simpler in some ways, but there are specific reasons
why the NixOS community (and the wiki) generally steers you toward the `legacy`
mount method.

If you remove `fileSystems` entries and use ZFS automounting:

- **Pros:**
  1. **Less Config:** Your disks.nix becomes much shorter. You just need
     `boot.zfs.extraPools`.
  2. **Portable:** The mount point is a property of the dataset itself. If you
     move the drives to another machine (even non-NixOS), they will try to mount
     at the same place automatically.

- **Cons (The "Why Not"):**
  1. **Boot Ordering Issues:** Systemd is very particular about dependency
     ordering. If a service (like Plex or a backup script) starts before ZFS has
     finished importing and mounting the pool, the service will fail or write
     data to the empty directory on the root drive.
     - _With `fileSystems`:_ NixOS generates systemd mount units. You can say
       `systemd.services.plex.requires = ["mnt-plex.mount"]`, ensuring Plex
       never starts until the drive is ready.
     - _With Automount:_ Systemd doesn't really know about these mounts. It
       just knows "ZFS started." It might not wait for the specific dataset to
       be available.
  2. **Declarative Purity:** NixOS philosophy is that your configuration file
     should describe the state of the system.
     - If you use automounting, the mount point is "hidden" inside the ZFS
       metadata on the disk, not visible in your disks.nix.
     - If you use `fileSystems`, your config explicitly says "This dataset goes
       here."

  3. **Empty Directory Issues:** If ZFS fails to mount (e.g., pool error), the
     directory `/mnt/plex` might still exist (as a folder on your root drive).
     Applications might silently fill up your root partition writing to it.
     `fileSystems` mounts handle this more gracefully by failing the
     dependency.

[NixOS Wiki - ZFS](https://wiki.nixos.org/wiki/ZFS)
