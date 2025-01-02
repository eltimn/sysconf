{
  description = "Go/Templ Application";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";

    templ.url = "github:a-h/templ/v0.3.819";
  };

  outputs =
    {
      self,
      nixpkgs,
      nixpkgs-unstable,
      templ,
    }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" ];
      # [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      forAllSystems =
        f:
        nixpkgs.lib.genAttrs supportedSystems (
          system:
          f {
            inherit system;
            pkgs = import nixpkgs { inherit system; };
            pkgs-unstable = import nixpkgs-unstable { inherit system; };
          }
        );

      templForSystem = system: templ.packages.${system}.templ;

      goPkgName = "go"; # 1.23
      nodePkgName = "nodejs_22";
    in
    {
      devShell = forAllSystems (
        {
          system,
          pkgs,
          pkgs-unstable,
          ...
        }:
        let
          goPkg = pkgs.${goPkgName};
          nodePkg = pkgs.${nodePkgName};
          templPkg = templForSystem (system);
        in
        pkgs.mkShell {
          buildInputs =
            with pkgs;
            [
              esbuild
              tailwindcss
            ]
            ++ [
              goPkg
              nodePkg
              templPkg
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
            CGO_ENABLED = 1;
          };

          shellHook = ''
            echo "Welcome to Go/Templ App!"
            echo "`${goPkg}/bin/go version`"
            echo "templ: `${templPkg}/bin/templ --version`"
            echo "node: `${nodePkg}/bin/node --version`"
            echo "npm: `${nodePkg}/bin/npm --version`"
          '';
        }
      );
    };
}
