# sysconf

## Usage

Tasks are run using [task](https://taskfile.dev). Use `task --list` to see the available tasks, or see Taskfile.yml. The build and switch tasks should automatically figure out which nix command (home-manager or nixos-rebuild) to use.

For running the first time, use a nix shell to use the task app:

```shell
nix shell nxpkgs#go-task
```

## References
* https://nix-community.github.io/home-manager/options.xhtml
* https://github.com/Yumasi/nixos-home/tree/main
* https://github.com/chrisportela/dotfiles
* https://www.chrisportela.com/posts/home-manager-flake/

## Notes

Use [caligula](https://github.com/ifd3f/caligula) in a nix shell to write to USB drives.

```shell
$ nix-shell -p caligula
[nix-shell:~/Downloads]$ caligula burn <file>.iso
```

### Nix pkgs bin directory
- NixOS: /etc/profiles/per-user/nelly/bin
- Nix on Pop_OS!: /home/nelly/.nix-profile/bin

### Misc commands
```shell
nix profile history --profile /nix/var/nix/profiles/system # list all versions
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 1d  # wipe out old histories, similar to collect garbage with --delete-old flag
```
