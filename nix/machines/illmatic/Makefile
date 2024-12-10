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
	nix-collect-garbage --delete-old

.PHONY: all build switch clean update gc
