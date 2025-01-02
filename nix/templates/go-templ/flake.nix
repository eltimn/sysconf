{
  description = "Go/Templ Application";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
  };

  outputs =
    {
      self,
      nixpkgs,
    }:
    let
      # System types to support.
      supportedSystems = [ "x86_64-linux" ];
      # [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

      #   goVersion = 22; # Change this to update the whole stack
      #   overlays = [ (final: prev: { go = prev."go_1_${toString goVersion}"; }) ];
      # Nixpkgs instantiated for supported system types.
      nixpkgsFor = forAllSystems (system: import nixpkgs { inherit system; });

      goPkgName = "go"; # 1.23
      nodePkgName = "nodejs_22";
      templPkgName = "templ";
    in
    {
      # Add dependencies that are only needed for development
      devShells = forAllSystems (
        system:
        let
          pkgs = nixpkgsFor.${system};
          goPkg = pkgs.${goPkgName};
          nodePkg = pkgs.${nodePkgName};
          templPkg = pkgs.${templPkgName};
        in
        {
          default = pkgs.mkShell {
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

            packages = with pkgs; [
              air
              atlas
              go-task
              go-tools
              golangci-lint
              gopls
              gotools
              sqlite
            ];

            # env = {

            # };

            shellHook = ''
              echo "Welcome to Go/Templ App!"
              echo "`${goPkg}/bin/go version`"
              echo "templ: `${templPkg}/bin/templ --version`"
              echo "node: `${nodePkg}/bin/node --version`"
              echo "npm: `${nodePkg}/bin/npm --version`"
            '';
          };
        }
      );

      # The default package for 'nix build'. This makes sense if the
      # flake provides only one package or there is a clear "main"
      # package.
      # defaultPackage =
      #   forAllSystems (system: self.packages.${system}.server);
    };
}
