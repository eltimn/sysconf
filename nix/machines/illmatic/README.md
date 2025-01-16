# nix-home-manager

## Ubuntu 20.04

* Create the user
* Add user to extra groups `sudo usermod -a -G <group> nelly` (not sure if all are needed)
  * adm
  * cdrom
  * sudo
  * dip
  * www-data
  * plugdev
  * lxd
  * docker

## Run ansible playbook

```shell
cd ~/sysconf/ansible
ansible-playbook --ask-become-pass nas.yml
```

### Manually restore secrets

### Run `make` in ~/secret/dotfiles

## Run bootstrap script
* Download bootstrap.sh from github or get from USB backup and place in your home directory
* Run `bootstrap.sh [workstation|laptop]`
* Delete bootstrap.sh

## Setup home manager
* See switch command switch above.