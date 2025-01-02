#!/usr/bin/env bash
#
# Sets what nix command to use for this host.

if [ -f /etc/NIXOS ]; then
  echo -n "sudo nixos-rebuild"
  exit 0
fi

echo -n "home-manager"
exit 0
