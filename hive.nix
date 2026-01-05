{ inputs, pkgs-unstable, ... }:
{
  "nixos-test-01" = {
    deployment = {
      targetHost = "nixos-test-01.eltimn.com";
      targetUser = "sysconf";
      targetPort = 22;

      # Deployment keys for user passwords
      keys = {
        "nelly-password" = {
          keyCommand = [
            "cat"
            "/home/nelly/secret/sysconf/colmena/nelly-password.txt"
          ];
          destDir = "/run/keys";
          user = "root";
          group = "root";
          permissions = "0400";
        };
      };
    };

    imports = [
      ./nix/machines/nixos-test/configuration.nix
      ./nix/settings.nix
      inputs.home-manager.nixosModules.home-manager
    ];

    sysconf.settings.hostName = "nixos-test-01";
    sysconf.settings.primaryUsername = "sysconf";

    # Home Manager configuration for users
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.nelly = {
        imports = [
          ./nix/machines/nixos-test/home-nelly.nix
        ];
      };
      extraSpecialArgs = {
        inherit pkgs-unstable;
      };
      sharedModules = [ ];
    };
  };
}
