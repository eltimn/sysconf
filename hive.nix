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
  cbox = {
    deployment = {
      targetHost = "cbox";
      targetUser = "sysconf";
      targetPort = 22;
      keys = mkPasswordKeys;
      tags = [ "local" ];
    };

    imports = [
      inputs.disko.nixosModules.disko
      ./nix/machines/cbox/disks.nix
      ./nix/machines/cbox/hardware-configuration.nix
      ./nix/machines/cbox/system.nix
      ./nix/modules/system
      inputs.home-manager.nixosModules.home-manager
    ];

    sysconf.settings.hostName = "cbox";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.nelly = {
        imports = [
          ./nix/machines/cbox/home.nix
        ];
      };
      extraSpecialArgs = { inherit pkgs-unstable; };
      sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    };
  };

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
      ./nix/machines/illmatic/disks.nix
      ./nix/machines/illmatic/hardware-configuration.nix
      ./nix/machines/illmatic/system.nix
      ./nix/modules/system
      inputs.home-manager.nixosModules.home-manager
    ];

    sysconf.settings.hostName = "illmatic";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.nelly = {
        imports = [
          ./nix/machines/illmatic/home.nix
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
      ./nix/machines/nixos-test/configuration.nix
      ./nix/modules/system
      inputs.home-manager.nixosModules.home-manager
    ];

    sysconf.settings.hostName = "nixos-test-01";

    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      users.nelly = {
        imports = [ ./nix/machines/nixos-test/home-nelly.nix ];
      };
      extraSpecialArgs = { inherit pkgs-unstable; };
      sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
    };
  };
}
