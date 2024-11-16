# sysconf-laptop

## Rebuild with current files
```shell
sudo nixos-rebuild switch --flake .#laptop
```

## Upgrade Packages

In `flake.nix` change the `nixpkgs.url` and `home-manager.url` inputs to the desired channel.

Run:
```shell
sudo nix flake update
```

Then rebuild.
