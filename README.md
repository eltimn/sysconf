# sysconf

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