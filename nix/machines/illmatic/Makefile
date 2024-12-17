all: switch dotfiles

build:
	nixos-rebuild build --flake .#illmatic

switch:
	sudo nixos-rebuild switch --flake .#illmatic

clean:
	rm -rf result

update:
	sudo nix flake update

gc:
	sudo nix-collect-garbage --delete-older-than 7d # system wide
	nix-collect-garbage --delete-older-than 7d # home-manager stuff in user's home directory

dotfiles:
	stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles zsh

clean-dotfiles:
	stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles zsh

.PHONY: all build switch clean update gc dotfiles clean-dotfiles
