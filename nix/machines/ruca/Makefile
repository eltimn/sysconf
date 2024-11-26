.PHONY: build switch clean update
build:
	nix run . -- build --flake .

switch:
	nix run . -- switch --flake .

clean:
	rm -rf result

update:
	nix flake update
