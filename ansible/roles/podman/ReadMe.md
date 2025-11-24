Call systemctl and journalctl as a different user

```shell
sudo machinectl shell <user>@.host /usr/bin/systemctl --user status <service_name>
sudo machinectl shell <user>@.host /usr/bin/journalctl --user -xeu <service_name> --follow
# e.g.
sudo machinectl shell podman@.host /usr/bin/systemctl --user status jellyfin.service
sudo machinectl shell podman@.host /usr/bin/journalctl --user -xeu jellyfin.service --follow
```
