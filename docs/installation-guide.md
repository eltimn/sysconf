# Installation

## Physical Computer

1. Use minimal ISO and manually create and format file systems or do beforehand if you have access to the disk. Don't use disko to format.
2. Don't try to use run-install.
3. Use the NixOS Manual Installation Guide.

TODO: Create a first install "host" machine configuration that doesn't include any SOPS secrets.

## Guide

1. Configure and format disks as described in [NixOS Manual Installation Guide](https://nixos.org/manual/nixos/stable/#sec-installation-manual) either beforehand or after booting into iso LiveCD.
2. Boot into iso LiveCD.
3. Set some env vars:
```shell
export TARGET_HOST=illmatic
export SELECTED_BRANCH=wip_illmatic_nixos
```
4. Clone the sysconf repo and switch to the appropriate branch.
```shell
git clone https://github.com/eltimn/sysconf.git "$HOME/sysconf"
git checkout -t "$SELECTED_BRANCH"
```
5. Generate the hardware configuration and make any changes needed.
```shell
nixos-generate-config \
	--dir $HOME/sysconf/nix/machines/$TARGET_HOST \
	--no-filesystems
```
6. Add the hardware-configuration.nix to git.
```shell
git -C $HOME/sysconf add \
	$HOME/sysconf/nix/machines/$TARGET_HOST/hardware-configuration.nix
```
7. Run the install
```shell
sudo nixos-install --no-root-passwd --flake "$HOME/sysconf#$TARGET_HOST"
```
8. Set a password for the primary user. See the manual.
```shell
sudo nixos-enter --root /mnt -c 'passwd nelly'
```
9. Copy any code changes to the new system. Will include `hardware-configuration.nix`.
```shell
mkdir -p /mnt/home/nelly/sysconf-install
cp -r $HOME/sysconf /mnt/home/nelly
```

## After First Boot

1. Get age version of host's public ssh key.
```shell
# using the sysconf dev shell
cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
```
2. Create user's ssh key. See [Github SSH Guide](https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent).
```shell
ssh-keygen -t ed25519 -C "your_email@example.com"
```
3. Get age version of user's ssh key.
```shell
cat ~/.ssh/id_ed25519.pub | ssh-to-age
```
4. Add the age keys to `.sops.yaml` to allow decryption of secrets. See [sops](sops.md).
5. Add the primary user's public ssh key to `settings.nix`.
