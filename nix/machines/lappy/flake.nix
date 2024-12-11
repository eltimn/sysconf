{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.11";
    home-manager = {
      # If using unstable channel, remove release tag.
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      home-manager,
    }:
    let
      system = "x86_64-linux";

      vars = {
        user = "nelly";
        host = "lappy";
        editor = "nvim";
      };
    in
    {
      nixosConfigurations = {
        laptop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            inherit inputs vars;
          };
          modules = [
            ./hardware-configuration.nix
            ./configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager = {
                useGlobalPkgs = true;
                useUserPackages = true;
                users.${vars.user} = import ./home.nix;

                # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
                extraSpecialArgs = {
                  inherit vars;
                };
              };
            }
          ];
        };
      };
    };
}
