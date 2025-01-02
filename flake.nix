{
  # https://nixos.wiki/wiki/Flakes
  # Inspiration: https://github.com/the-nix-way/nome";
  description = "NixOS and Home Manager configurations for all machines";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    {
      nixpkgs,
      home-manager,
      ...
    }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      loadVars = host: builtins.fromTOML (builtins.readFile ./nix/machines/${host}/settings.toml);

      # a function to create a home manager configuration
      hmConfig =
        host:
        home-manager.lib.homeManagerConfiguration {
          inherit pkgs;

          # Specify your home configuration modules here, for example,
          # the path to your home.nix.
          modules = [ ./nix/machines/${host}/home.nix ];

          # Optionally use extraSpecialArgs
          # to pass through arguments to home.nix
          extraSpecialArgs = {
            # load the settings
            vars = loadVars host;
          };
        };

      # a function to create a nixos configuration
      nixosConfig =
        host:
        let
          vars = loadVars host;
        in
        nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs vars;
          };
          modules = [
            ./nix/machines/${vars.host}/hardware-configuration.nix
            ./nix/machines/${vars.host}/system.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${vars.user} = import ./nix/machines/${vars.host}/home.nix;

                # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
                extraSpecialArgs = {
                  inherit vars;
                };
              };
            }
          ];
        };
    in
    {
      # so you can use `nix run . -- switch --flake .`
      # defaultPackage.${system} = home-manager.defaultPackage.${system};

      # Home Manager configurations. Non-nixos hosts.
      homeConfigurations = {
        "nelly@ruca" = hmConfig "ruca";
        "nelly@illmatic" = hmConfig "illmatic";
      };

      nixosConfigurations = {
        cbox = nixosConfig "cbox";
        lappy = nixosConfig "lappy";
      };

      # tools for managing this repository and the host machines
      devShells.${system}.default = pkgs.mkShell {
        packages = with pkgs; [
          go-task
          nixos-generators
        ];

        env = {
          DUMMY_VAR = "templ";
        };

        shellHook = ''
          echo "Welcome to sysconf!"
        '';
      };

      templates = {
        go-templ = {
          path = ./nix/templates/go-templ;
          description = "A go/templ flake";
        };
      };

    };
}