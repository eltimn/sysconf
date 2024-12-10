.PHONY: switch
switch:
	sudo nixos-rebuild switch --flake .#cbox

.PHONY: update
update:
	sudo nix flake update

.PHONY: gc
gc:
	sudo nix-collect-garbage --delete-old # system wide
	nix-collect-garbage --delete-old # home-manager stuff in user's home directory

