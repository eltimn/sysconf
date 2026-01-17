# SOPS

```shell
# convert the host public ssh key to AGE
cat /etc/ssh/ssh_host_ed25519_key.pub | ssh-to-age
# convert the user's public ssh key to AGE (only works if it's not password protected)
cat ~/.ssh/id_ed25519.pub | ssh-to-age
# Add the output to .sops.yaml, then run:
sops updatekeys secrets/*

# Use an existing private ssh key to create an age key.
mkdir -p $HOME/.config/sops/age/
read -s SSH_TO_AGE_PASSPHRASE; export SSH_TO_AGE_PASSPHRASE
nix run nixpkgs#ssh-to-age -- \
  -private-key \
  -i $HOME/.ssh/id_ed25519 \
  -o $HOME/.config/sops/age/keys.txt

(The SSH_TO_AGE_PASSPHRASE option is documented in the [ssh-to-age README](https://github.com/Mic92/ssh-to-age/blob/main/README.md#usage).)
```
