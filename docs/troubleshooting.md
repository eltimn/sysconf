# Troubleshooting

If a system won't boot but has a configuration already:

1. Boot into the live cd
2. Mount the main disks as described in the [NixOS Manual Installation Guide](https://nixos.org/manual/nixos/stable/#sec-installation-manual-installing)
```shell
# should be available in iso as `mount-disks`
sudo mount /dev/disk/by-label/nixos /mnt
# UEFI systems
sudo mkdir -p /mnt/boot
sudo mount -o umask=077 /dev/disk/by-label/boot /mnt/boot
sudo lsblk /mnt/boot
```
4. Make any necessary configuration changes.
5. Use [nixos-enter](https://wiki.nixos.org/wiki/Change_root) to run rebuild command:
```shell
sudo nixos-enter # --root /mnt # default
# once inside you'll be root
cd /home/nelly/sysconf
nixos-rebuild boot --flake .#hostname
```
