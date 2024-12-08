switch:
	sudo nixos-rebuild switch --flake .#laptop

update:
	sudo nix flake update

gc:
	sudo nix-collect-garbage --delete-old

dotfiles:
	stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles code
	stow --verbose --stow --dotfiles --target=$$HOME --dir=$$HOME/sysconf/dotfiles wezterm

clean-dotfiles:
	stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles code
	stow --verbose --delete --target=$$HOME --dir=$$HOME/sysconf/dotfiles wezterm

.PHONY: switch update gc dotfiles clean-dotfiles

