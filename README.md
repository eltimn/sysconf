# sysconf

## Usage

Tasks are run using [Task](https://taskfile.dev). Use `task --list` to see the available tasks, or see Taskfile.yml. The build and switch tasks should automatically figure out which nix command (home-manager or nixos-rebuild) and host to use. The boot task allows adding a command line parameter (`task boot -- cbox`) to select the host.

For running the first time, use a nix shell to use the task app:

```shell
nix shell nxpkgs#go-task
```

## Notes

Use [caligula](https://github.com/ifd3f/caligula) to write to USB drives.

```shell
caligula burn <file>.iso
```

### Nix pkgs bin directory
- NixOS: /etc/profiles/per-user/nelly/bin
- Nix on Pop_OS!: /home/nelly/.nix-profile/bin

### Misc commands
```shell
nix profile history --profile /nix/var/nix/profiles/system # list all versions
sudo nix profile wipe-history --profile /nix/var/nix/profiles/system --older-than 1d  # wipe out old histories, similar to collect garbage with --delete-old flag
```

### Installation

See [Installation Guide](./docs/installation-guide.md)


## Resources
* https://nix-community.github.io/home-manager/options.xhtml
* https://github.com/Yumasi/nixos-home/tree/main
* https://github.com/chrisportela/dotfiles
* https://www.chrisportela.com/posts/home-manager-flake/
* https://gitlab.com/hmajid2301/nixicle
* https://tsawyer87.github.io/posts/top_level_attributes_explained/
