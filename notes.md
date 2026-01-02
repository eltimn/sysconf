In order to build locally and deploy to another computer, there are 2 choices:

### 1. Allow root to ssh to the server. Add this to the users.users section:

```
users = {
  users = {
    "${config.sysconf.settings.primaryUsername}" = {
        ... existing config ...
    };

    root = {
      openssh.authorizedKeys.keys = config.sysconf.settings.primaryUserSshKeys;
    };
  };
};
```

And set remote host to allow root login in sshd settings:
```shell
PermitRootLogin = "yes"
```

### 2. Use the user account with sudo

If you'd rather not enable root SSH, you can use:

```
sudo nixos-rebuild switch --flake .#illmatic \
  --target-host nelly@illmatic \
  --build-host localhost \
  --sudo
```

This connects as nelly, then uses sudo on the remote side. But your current user needs passwordless sudo for this to work

```shell
# Allow wheel group to use sudo without password
security.sudo.wheelNeedsPassword = false;

```
