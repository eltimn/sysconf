# cbox


```shell
sudo nixos-rebuild switch --flake '.#cbox' # switch to the latest config
sudo nix-collect-garbage --delete-old # delete all old and unused packages
nix profile history --profile /nix/var/nix/profiles/system # list all versions
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 1d  # wipe out old histories, similar to collect garbage with --delete-old flag
```