# ISO

This ISO includes helper scripts for manual bare-metal installs:

- `prepare-key` (optional): puts a SOPS age key at `$HOME/.config/sops/age/keys.txt`
- `mount-disks`: mounts install target by filesystem labels
- `run-install`: clones `sysconf` and runs `nixos-install --flake`

## Disk Formatting (UEFI)

`mount-disks` expects these filesystem labels:

- EFI System Partition (vfat): label `boot` mounted at `/mnt/boot`
- Root filesystem (ext4): label `nixos` mounted at `/mnt`

If the disk contains old partitions and/or volume manager metadata (e.g. LVM),
wipe signatures first:

```bash
# Example LVM PV on /dev/sda3
sudo vgchange -an ubuntu-vg 2>/dev/null || true
sudo lvchange -an ubuntu-vg/ubuntu-lv 2>/dev/null || true
sudo pvremove -ff -y /dev/sda3

# All disks
sudo wipefs -a /dev/sda3
sudo wipefs -a /dev/sda

# Overwrite data (more secure):
sudo dd if=/dev/zero of=/dev/sda3 bs=1M status=progress

# Wipes GPT and MBR partition tables:
sudo sgdisk --zap-all /dev/sda
```

Example layout for `/dev/sda` (DESTROYS ALL DATA on that disk):

```bash
# Create GPT and partitions
sudo parted /dev/sda -- mklabel gpt
sudo parted /dev/sda -- mkpart ESP fat32 1MiB 513MiB
sudo parted /dev/sda -- set 1 esp on
sudo parted /dev/sda -- mkpart swap linux-swap -8GB 100%
sudo parted /dev/sda -- mkpart nixos ext4 513MiB 100%

# Format with labels the scripts expect
sudo mkfs.fat -F 32 -n boot /dev/sda1
sudo mkfs.ext4 -L nixos /dev/sda2

# Mount for installation
sudo mount-disks
findmnt /mnt /mnt/boot
```

For BTRFS, see [NixOS Wiki: BTRFS](https://wiki.nixos.org/wiki/Btrfs) and refer
to the mount-disks script for expected labels.

## Bootstrap Note

`run-install` installs from a flake, so it expects to be able to `git clone`
this `sysconf` repo during the install environment.

If the target machine will not have outbound network access during installation,
a minimal “bootstrap” host configuration (embedded into the ISO) can be useful
so you only need to bring up SSH first and then deploy the full config remotely.

## Secrets

You'll need access to the SOPS keys during installation. Copy the one
on Ruca to a USB drive and run `prepare-key` to put it in the right place.

## Troubleshooting

If a system won't boot but has a configuration already:

1. Boot into the live cd
2. Mount the disks using `mount-disks ext4|btrfs`
3. Make any necessary configuration changes by going to `/home/nelly/sysconf` on
   the mounted drive.
4. Use [nixos-enter](https://wiki.nixos.org/wiki/Change_root) to run rebuild command:

```shell
sudo nixos-enter # --root /mnt # default
# once inside you'll be root
cd /home/nelly/sysconf
nixos-rebuild boot --flake .#hostname
```

The next boot should reflect the changes you made.

## Resources

- [building-bootable-iso-image](https://nix.dev/tutorials/nixos/building-bootable-iso-image.html)
- [how-to-create-a-custom-nixos-iso](https://haseebmajid.dev/posts/2024-02-04-how-to-create-a-custom-nixos-iso/)
- [disko](https://github.com/nix-community/disko)
