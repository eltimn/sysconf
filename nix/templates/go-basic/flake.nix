{
  description = "Go Application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
    }:
    let
      # System types to support.
      supportedSystems = [
        "x86_64-linux"
        "x86_64-darwin"
        "aarch64-linux"
        "aarch64-darwin"
      ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs {
              inherit system;
              overlays = [ self.overlays.default ];
            };
            pkgs-unstable = import nixpkgs-unstable {
              inherit system;
              overlays = [ self.overlays.default ];
            };
          }
        );

      goPkgName = "go"; # 1.23
      cgoEnabled = 0;
    in
    {
      # overlays to use a specific version as the main package
      overlays.default = final: prev: {
        go = prev.${goPkgName};
      };

      devShell = forAllSystems (
        {
          system,
          pkgs,
          pkgs-unstable,
          ...
        }:
        pkgs.mkShell {
          buildInputs = with pkgs; [
            go
          ];

          packages =
            with pkgs;
            [
              go-tools
              golangci-lint
              gotools
            ]
            ++ [ pkgs-unstable.gopls ];

          env = {
            CGO_ENABLED = cgoEnabled;
          };

          shellHook = ''
            echo "Welcome to Go App!"
            echo "`${pkgs.go}/bin/go version`"
          '';
        }
      );
    };
}
