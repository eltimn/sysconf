.PHONY: build switch clean update clean-dotfiles
build:
	nix run . -- build --flake .

switch:
	nix run . -- switch --flake .
	stow --verbose --stow --dotfiles --target=$$HOME --dir=../../../dotfiles code

clean:
	rm -rf result

update:
	nix flake update

clean-dotfiles:
	stow --verbose --delete --target=$$HOME --dir=../../../dotfiles code