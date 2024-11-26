{
  description = "sysconf ansible";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config.allowUnfree = true;
        };
      in {
        devShells.default = pkgs.mkShell {
          packages = with pkgs;
            [
              ansible
              caddy
            ];

          shellHook = ''
            echo "Welcome to sysconf ansible!"
          '';

          env = { NIXPKGS_ALLOW_UNFREE = 1; };
        };
      });

}
