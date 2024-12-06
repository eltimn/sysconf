{
  # https://nixos.wiki/wiki/Flakes
  # Inspiration: https://github.com/the-nix-way/nomey/home-manager";
  description = "Home Manager configuration of nelly";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "x86_64-linux";
      # pkgs = nixpkgs.legacyPackages.${system};
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      username = "nelly";

      # Variables Used In Flake
      vars = {
        user = "nelly";
        # location = "$HOME/.setup";
        # terminal = "kitty";
        editor = "nvim";
      };
    in
    {
      # needed for `nix run`
      defaultPackage.x86_64-linux = home-manager.defaultPackage.x86_64-linux;

      homeConfigurations."${vars.user}" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home.nix ];

        # Optionally use extraSpecialArgs
        # to pass through arguments to home.nix
        extraSpecialArgs = {
          inherit vars;
        };
      };

    };
}