all: switch

build:
	nix run . -- build --flake .

switch:
	nix run . -- switch --flake .

clean:
	rm -rf result

update:
	nix flake update

gc:
	nix-collect-garbage --delete-old # home-manager stuff in user's home directory

dotfiles:
	stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles code
	stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles wezterm
	stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles zsh
	# stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles zellij

clean-dotfiles:
	stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles code
	stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles wezterm
	stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles zsh
	# stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles zellij

.PHONY: all build switch clean update gc dotfiles clean-dotfiles
