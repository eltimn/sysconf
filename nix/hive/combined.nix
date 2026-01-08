{ inputs, pkgs-unstable, ... }:
let
  # Shared secret definitions for user passwords
  mkPasswordKeys = {
    "nelly-password" = {
      keyCommand = [
        "sops"
        "--extract"
        "[\"users\"][\"nelly\"][\"password\"]"
        "--decrypt"
        "secrets/secrets-enc.yaml"
      ];
      destDir = "/run/keys";
      user = "root";
      group = "root";
      permissions = "0400";
    };
  };
in
{
  ## Local hosts ##
  # cbox = {
  #   deployment = {
  #     targetHost = "cbox";
  #     targetUser = "sysconf";
  #     targetPort = 22;
  #     keys = mkPasswordKeys;
  #     tags = [ "local" ];
  #   };

  #   imports = [
  #     inputs.disko.nixosModules.disko
  #     ../machines/cbox/disks.nix
  #     ../machines/cbox/hardware-configuration.nix
  #     ../machines/cbox/system.nix
  #     ../modules/system
  #     inputs.home-manager.nixosModules.home-manager
  #   ];

  #   sysconf.settings.hostName = "cbox";
  #   sysconf.settings.primaryUsername = "nelly";

  #   home-manager = {
  #     useGlobalPkgs = true;
  #     useUserPackages = true;
  #     users.nelly = {
  #       imports = [
  #         ../machines/cbox/home.nix
  #         inputs.cosmic-manager.homeManagerModules.cosmic-manager
  #       ];
  #     };
  #     extraSpecialArgs = { inherit pkgs-unstable; };
  #     sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
  #   };
  # };

  illmatic = {
    deployment = {
      targetHost = "illmatic";
      targetUser = "sysconf";
      targetPort = 22;
      keys = mkPasswordKeys // {
        # Caddy needs Cloudflare credentials
        "caddy-env" = {
          keyCommand = [
            "sops"
            "--decrypt"
            "secrets/caddy-enc.env"
          ];
          destDir = "/run/keys";
          user = "caddy";
          group = "caddy";
          permissions = "0400";
        };
      };
      tags = [ "local" ];
    };

    imports = [
      inputs.disko.nixosModules.disko
      ../machines/illmatic/disks.nix
      ../machines/illmatic/hardware-configuration.nix
      ../machines/illmatic/system.nix
      ../modules/system
      inputs.home-manager.nixosModules.home-manager
    ];

    sysconf.settings.hostName = "illmatic";
    sysconf.settings.primaryUsername = "nelly";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.nelly = {
        imports = [
          ../machines/illmatic/home.nix
          inputs.cosmic-manager.homeManagerModules.cosmic-manager
        ];
      };
      extraSpecialArgs = { inherit pkgs-unstable; };
      sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    };
  };

  ## Digital Ocean (DO) hosts ##
  nixos-test-01 = {
    deployment = {
      targetHost = "nixos-test-01.eltimn.com";
      targetUser = "sysconf";
      targetPort = 22;
      keys = mkPasswordKeys;
      tags = [
        "do"
        "digitalocean"
      ];
    };

    imports = [
      ../machines/nixos-test/configuration.nix
      ../modules/system
      inputs.home-manager.nixosModules.home-manager
    ];

    sysconf.settings.hostName = "nixos-test-01";
    sysconf.settings.primaryUsername = "nelly";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.nelly = {
        imports = [ ../machines/nixos-test/home-nelly.nix ];
      };
      extraSpecialArgs = { inherit pkgs-unstable; };
      sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    };
  };
}
