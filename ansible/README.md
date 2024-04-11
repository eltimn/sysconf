## Home Server (illmatic)

For copying files use sshfs and mount to a local directory:
```shell
mkdir -p ~/illmatic/mnt
sshfs illmatic.home.eltimn.com:/mnt ~/illmatic/mnt
```

# Channels DVR
* installed manually https://getchannels.com/dvr-server/#linux

## Nvidia Shield

For copying files follow these steps:

* Enable "Transfer files over local network" on Shield in Settings -> Device Preferences -> Storage. Clicking on that will show the connection info needed (user, password, etc.).
* In File Manager go to Other Locations and enter ```smb://192.168.1.49``` in the "Connect to Server" form at the bottom of the window.
