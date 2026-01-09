{
  inputs,
  lib,
  pkgs-unstable,
  ...
}:
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

  # a function to create a colmena configuration
  colmenaConfig =
    fqdn: tags: deploymentKeys:
    let
      hostName = builtins.head (lib.strings.splitString "." fqdn);
    in
    {

      deployment = {
        targetHost = fqdn;
        targetUser = "sysconf";
        targetPort = 22;
        keys = deploymentKeys;
        tags = tags;
      };

      sysconf.settings.hostName = hostName;

      imports = [
        inputs.disko.nixosModules.disko
        ./nix/machines/${hostName}/configuration.nix
        ./nix/modules/system
        inputs.home-manager.nixosModules.home-manager
      ];

      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        users.nelly = {
          imports = [
            ./nix/machines/${hostName}/home-nelly.nix
            ./nix/modules/home # home manager modules
          ];
        };
        extraSpecialArgs = { inherit pkgs-unstable; };
        sharedModules = [ inputs.sops-nix.homeManagerModules.sops ];
      };
    };

  illmaticKeys = mkPasswordKeys // {
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
in
{
  ## Local hosts ##
  cbox = colmenaConfig "cbox" [ "local" ] mkPasswordKeys;
  illmatic = colmenaConfig "illmatic" [ "local" ] illmaticKeys;

  ## Digital Ocean (DO) hosts ##
  nixos-test-01 = colmenaConfig "nixos-test-01.eltimn.com" [ "do" "digitalocean" ] mkPasswordKeys;
}
