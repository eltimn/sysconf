# SOPS

```shell
# convert the host public ssh key to AGE
cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
# Add the output to .sops.yaml, then run:
sops updatekeys secrets/caddy-enc.env
sops updatekeys secrets/secrets-enc.yaml
```
