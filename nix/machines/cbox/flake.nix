{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager = {
      # If using unstable channel, remove release tag.
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, home-manager }:
    let
      system = "x86_64-linux";
      username = "nelly";
    in {
      nixosConfigurations = {
        cbox = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = { inherit inputs; };
          modules = [
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${username} = import ./home.nix;

                # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
                extraSpecialArgs = { inherit username; };
              };
            }
          ];
        };
      };
    };
}

