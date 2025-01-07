{
  description = "Go/Templ Application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    templ-flake.url = "github:a-h/templ/v0.3.819";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      templ-flake,
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

      nodePkgName = "nodejs_22";
      goPkgName = "go"; # 1.23
      cgoEnabled = 1;
    in
    {
      # overlays to use a specific version as the main package
      overlays.default = final: prev: {
        nodejs = prev.${nodePkgName};
        go = prev.${goPkgName};
        templ = templ-flake.packages.${prev.system}.templ;
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
            esbuild
            go
            nodejs
            tailwindcss
            templ
          ];

          packages =
            with pkgs;
            [
              air
              atlas
              go-task
              go-tools
              golangci-lint
              gotools
              sqlite
            ]
            ++ [ pkgs-unstable.gopls ];

          env = {
            CGO_ENABLED = cgoEnabled;
          };

          shellHook = ''
            echo "Welcome to Go/Templ App!"
            echo "`${pkgs.go}/bin/go version`"
            echo "templ: `${pkgs.templ}/bin/templ --version`"
            echo "node: `${pkgs.nodejs}/bin/node --version`"
            echo "npm: `${pkgs.nodejs}/bin/npm --version`"
          '';
        }
      );
    };
}
