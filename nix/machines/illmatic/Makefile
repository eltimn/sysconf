all: switch dotfiles

build:
	nix run . -- build --flake .

switch:
	nix run . -- switch --flake .

clean:
	rm -rf result

update:
	nix flake update

gc:
	nix-collect-garbage --delete-old

dotfiles:
	stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles zsh

clean-dotfiles:
	stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles zsh


.PHONY: all build switch clean update gc dotfiles clean-dotfiles
