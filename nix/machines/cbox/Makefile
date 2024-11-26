.PHONY: switch
switch:
	sudo nixos-rebuild switch --flake .#cbox

.PHONY: upgrade
upgrade:
	sudo nix flake update

.PHONY: gc
gc:
	sudo nix-collect-garbage --delete-old
