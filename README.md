# sysconf

## Notes

Use [caligula](https://github.com/ifd3f/caligula) in a nix shell to write to USB drives.

```shell
$ nix-shell -p caligula
[nix-shell:~/Downloads]$ caligula burn <file>.iso
```