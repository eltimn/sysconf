all: switch dotfiles

switch:
	sudo nixos-rebuild switch --flake .#cbox

update:
	sudo nix flake update

gc:
	sudo nix-collect-garbage --delete-old # system wide
	nix-collect-garbage --delete-old # home-manager stuff in user's home directory

dotfiles:
	stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles zsh

clean-dotfiles:
	stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles zsh

.PHONY: all switch update gc dotfiles clean-dotfiles
