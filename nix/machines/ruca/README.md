# nix-home-manager

## Directions

### Build without applying
```shell
make build
```

### Switch to current build
```shell
make switch
```

## Nix pkgs bin directory
NixOS: /etc/profiles/per-user/nelly/bin
Nix on Pop_OS!: /home/nelly/.nix-profile/bin

## Pop_OS! 22.04

* Install nvidia-driver-470 in Pop!_Shop for GeForce GT 710 video card.

## Prerequisites

### Install some apps manually
* install vivaldi
* ~~install chrome~~
* ~~install vscode~~
* ~~install filen (get password from enpass on phone)~~
* install filen via .deb
* install dropbox (get password from enpass on phone)
* wait for dropbox to sync

### Manually restore secrets and ssh files

### Run `make` in ~/secret/dotfiles

## Run bootstrap script
* Download bootstrap.sh from github or get from USB backup and place in your home directory
* Run `bootstrap.sh [workstation|laptop]`
* Delete bootstrap.sh

## Setup home manager
* See switch command switch above.

## Manual System Config
* Set mouse primary click to right.
* Set desktop background image to ~/Images/85942-Lightning_Neuro.jpg
* gnome-tweaks
  * Windows
    * enable minimize and maximize buttons
    * enable center new windows
* Add startup apps
  * Parcellite: /home/nelly/.nix-profile/bin/parcellite
  * Filen

=========================================================

## Run ansible playbook

```shell
cd ~/sysconf/ansible
ansible-playbook --ask-become-pass [workstation|laptop].yml
```

## Additional Manual Configuration

[Watch Videos and Play Music](https://support.system76.com/articles/codecs/)

### Install codecs
```shell
sudo apt install ubuntu-restricted-extras gstreamer1.0-plugins-bad
```
### Set up DVD Playback
```shell
sudo apt install -y libdvd-pkg
sudo dpkg-reconfigure libdvd-pkg
```

### Set swapiness ??
https://help.ubuntu.com/community/SwapFaq

### Printer
Go to system settings and add printer. Should be found on the network.

## Notes

### Brother Scanner

http://askubuntu.com/a/489920

## References

* [managing-your-dotfiles/using-gnu-stow](https://systemcrafters.net/managing-your-dotfiles/using-gnu-stow/)
* Use `testdisk` to check bad harddrive.
