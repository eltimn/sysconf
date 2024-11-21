.PHONY: build switch clean
build:
	nix run . -- build --flake .

switch:
	nix run . -- switch --flake .

clean:
	rm -rf result
