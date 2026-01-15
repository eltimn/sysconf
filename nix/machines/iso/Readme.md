# ISO

This ISO includes helper scripts for manual bare-metal installs:

- `prepare-key` (optional): puts a SOPS age key at `$HOME/.config/sops/age/keys.txt`
- `mount-disks`: mounts install target by filesystem labels
- `run-install`: clones `sysconf` and runs `nixos-install --flake`

## Disk Formatting (UEFI)

`mount-disks` expects these filesystem labels:

- EFI System Partition (vfat): label `boot` mounted at `/mnt/boot`
- Root filesystem (ext4): label `nixos` mounted at `/mnt`

Example layout for `/dev/sdb` (DESTROYS ALL DATA on that disk):

```bash
# Create GPT and partitions
sudo parted /dev/sdb -- mklabel gpt
sudo parted /dev/sdb -- mkpart ESP fat32 1MiB 513MiB
sudo parted /dev/sdb -- set 1 esp on
sudo parted /dev/sdb -- mkpart nixos ext4 513MiB 100%

# Format with labels the scripts expect
sudo mkfs.fat -F 32 -n boot /dev/sdb1
sudo mkfs.ext4 -L nixos /dev/sdb2

# Mount for installation
sudo mount-disks
findmnt /mnt /mnt/boot
```

If the disk contains old volume manager metadata (e.g. LVM), wipe signatures first:

```bash
# Example LVM PV on /dev/sdb3
sudo vgchange -an ubuntu-vg 2>/dev/null || true
sudo lvchange -an ubuntu-vg/ubuntu-lv 2>/dev/null || true
sudo pvremove -ff -y /dev/sdb3
sudo wipefs -a /dev/sdb3
sudo wipefs -a /dev/sdb

# If available:
sudo sgdisk --zap-all /dev/sdb
```

## Bootstrap Note

`run-install` installs from a flake, so it expects to be able to `git clone` this `sysconf` repo during the install environment.

If the target machine will not have outbound network access during installation, a minimal “bootstrap” host configuration (embedded into the ISO) can be useful so you only need to bring up SSH first and then deploy the full config remotely.

## Secrets

To get secrets on the host when installing:

- store keys in a separate repo
- after install, add new key to keys repo

## Resources
- [building-bootable-iso-image](https://nix.dev/tutorials/nixos/building-bootable-iso-image.html)
- [how-to-create-a-custom-nixos-iso](https://haseebmajid.dev/posts/2024-02-04-how-to-create-a-custom-nixos-iso/)
- [disko](https://github.com/nix-community/disko)
