#!/usr/bin/env bash
#
# Sets what nix command to use for this host.

if [ -f /etc/NIXOS ]; then
  echo -n "sudo nixos-rebuild"
else
  echo -n "home-manager"
fi

exit 0
