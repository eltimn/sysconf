all: switch

build:
	nix run . -- build --flake .

switch:
	nix run . -- switch --flake .

clean:
	rm -rf result

update:
	nix flake update

dotfiles:
	stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles code
	stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles wezterm
	# stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles zellij

clean-dotfiles:
	stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles code
	stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles wezterm
	# stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles zellij

.PHONY: all build switch clean update dotfiles clean-dotfiles
