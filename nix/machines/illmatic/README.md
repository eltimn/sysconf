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

## Ubuntu 22.04

* Create the user

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