# gocryptfs

# Auto-unmount after specified idle duration (ignored in reverse mode). Durations are specified like "500s" or "2h45m". 0 means stay mounted indefinitely.
--idle duration

```shell
gocryptfs --idle "2h" ~/secret-cipher ~/secret # mount
fusermount -u ~/secret                         # unmount

# store the password in seahorse and mount with --extpass
secret-tool store --label='gocryptfs - secret' gocryptfs secret
gocryptfs --extpass="secret-tool lookup gocryptfs secret" ~/secret-cipher ~/secret
```
